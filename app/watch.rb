require 'notify'

class Watch
  EPUB_RE = /\.epub\Z/io

  def initialize(work_dir, directories)
    raise ArgumentError, 'specify at least one directory' if directories.empty?
    @directories = directories.map {|dir| File.expand_path(dir)}
    @db = EPUB::Search::Database.new(File.join(work_dir, EPUB::Search::Database::DIR_NAME))
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
    catch_up
    Process.daemon if @daemonize
    begin
      Listen.to *@directories, :filter => EPUB_RE do |modified, added, removed|
        modified.each do |file_path|
          next unless file_path =~ EPUB_RE
          file_path.force_encoding 'UTF-8'
          begin
            $stderr.puts "remove #{file_path}"
            @db.remove file_path
            $stderr.puts "add #{file_path}"
            @db.add file_path
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
            @db.add file_path
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
            @db.remove file_path
            notify %Q|REMOVED:\n#{file_path}|
            FileUtils.touch exit_time_file
          rescue => error
            $stderr.puts error
            $stderr.puts error.backtrace if @debug
          end
        end
      end
    ensure
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

  def catch_up
    @directories.each do |dir|
      Dir["#{dir}/**/*.epub"].each do |file_path|
        next if File.file? exit_time_file and File.mtime(file_path) < exit_time
        begin
          removed = @db.remove(file_path)
          @db.add file_path
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
  end

  def notify(message)
    $stderr.puts message
    Notify.notify $PROGRAM_NAME, message if notify?
  end
end
