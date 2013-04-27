require 'notify'

class Watch
  EPUB_RE = /\.epub\Z/io
  PID_FILE_NAME = 'epub-search.pid'

  def initialize(work_dir, directories)
    raise ArgumentError, 'specify at least one directory' if directories.empty?
    @work_dir = Pathname === work_dir ? work_dir : Pathname.new(work_dir)
    @directories = directories.map {|dir| File.expand_path(dir)}
    @db = EPUB::Search::Database.new(File.join(@work_dir.to_path, EPUB::Search::Database::DIR_NAME))
  end

  def run(notify_on_change: true, daemonize: false, debug: false)
    @notify, @daemonize, @debug = notify_on_change, daemonize, debug
    if @debug
      $stderr.puts "notify_on_change: #{@notify}"
      $stderr.puts "daemonize: #{@daemonize}"
      $stderr.puts "debug: #{@debug}"
    end

    $PROGRAM_NAME = File.basename($PROGRAM_NAME)
    $stderr.puts 'start to watch:'
    @directories.each do |dir|
      $stderr.puts "  * #{dir}"
    end
    Process.daemon if @daemonize
    write_pid_file

    @actor = EPUB::Search::Database::Actor.new(@db)

    catch_up
    begin
      Listen.to! *@directories, :filter => EPUB_RE do |modified, added, removed|
        modified.each do |file_path|
          next unless file_path =~ EPUB_RE
          file_path.force_encoding 'UTF-8'
          begin
            $stderr.puts "update #{file_path}"
            @actor.async.update file_path
            title = EPUB::Parser.parse(file_path).title
            notify %Q|UPDATED: #{title}\n#{file_path}|
            FileUtils.touch exit_time_file
          rescue => error
            $stderr.puts error
            $stderr.puts error.backtrace if @debug
          end
        end
        added.each do |file_path|
          next unless file_path =~ EPUB_RE
          file_path.force_encoding 'UTF-8'
          begin
            @actor.async.add file_path
            title = EPUB::Parser.parse(file_path).title
            notify %Q|ADDED: #{title}\n#{file_path}|
            FileUtils.touch exit_time_file
          rescue => error
            $stderr.puts error
            $stderr.puts error.backtrace if @debug
          end
        end
        removed.each do |file_path|
          next unless file_path =~ EPUB_RE
          file_path.force_encoding 'UTF-8'
          begin
            @actor.async.remove file_path
            notify %Q|REMOVED:\n#{file_path}|
            FileUtils.touch exit_time_file
          rescue => error
            $stderr.puts error
            $stderr.puts error.backtrace if @debug
          end
        end
      end
    ensure
      pid_file.delete
      FileUtils.touch exit_time_file
    end
  end

  private

  def notify?
    @notify
  end

  def exit_time
    @exittime ||= File.mtime(exit_time_file)
  end

  def exit_time_file
    @db.db_dir.join('../exittime').to_path
  end

  def pid_file
    @work_dir + PID_FILE_NAME
  end

  def catch_up
    @directories.each do |dir|
      Dir["#{dir}/**/*.epub"].each do |file_path|
        next if File.file? exit_time_file and File.mtime(file_path) < exit_time
        begin
          removed = @actor.remove(file_path)
          @actor.async.add file_path
          operation = removed.zero? ? 'ADDED' : 'UPDATED'
          title = EPUB::Parser.parse(file_path).title
          notify "#{operation}: #{title}\n#{file_path}"
          FileUtils.touch exit_time_file
        rescue => error
          $stderr.puts error
          $stderr.puts error.backtrace if @debug
        end
      end
    end
  rescue
    pid_file.unlink
  end

  def write_pid_file
    if pid_file.exist?
      pid = pid_file.read.to_i
      begin
        Process.kill 0, pid
        raise "#{$PROGRAM_NAME}(pid: #{pid}) is running"
      rescue Errno::ESRCH
      end
    end
    $stderr.puts "pid: #{Process.pid}" if @debug
    pid_file.open 'wb' do |file|
      file.write Process.pid
    end
  end

  def notify(message)
    $stderr.puts message
    Notify.notify $PROGRAM_NAME, message if notify?
  end
end
