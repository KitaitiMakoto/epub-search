class Watch
  EPUB_RE = /\.epub\Z/io

  def initialize(db_file, directories)
    raise ArgumentError, 'specify at least one directory' if directories.empty?
    @directories = directories
    @db = EPUB::Search::Database.new(db_file)
  end

  def run
    $PROGRAM_NAME = File.basename($PROGRAM_NAME)
    $stderr.puts 'start to watch:'
    @directories.each do |dir|
      $stderr.puts "  * #{dir}"
    end
    catch_up
    begin
      Listen.to *@directories, :filter => EPUB_RE do |modified, added, removed|
        modified.each do |file_path|
          next unless file_path =~ EPUB_RE
          file_path.force_encoding 'UTF-8'
          begin
            @db.remove file_path
            @db.add file_path
            notify %Q|MODIFIED: #{file_path}|
          rescue => error
            $stderr.puts error
          end
        end
        added.each do |file_path|
          next unless file_path =~ EPUB_RE
          file_path.force_encoding 'UTF-8'
          begin
            @db.add file_path
            notify %Q|ADDED: #{file_path}|
          rescue => error
            $stderr.puts error
          end
        end
        removed.each do |file_path|
          next unless file_path =~ EPUB_RE
          file_path.force_encoding 'UTF-8'
          begin
            @db.remove file_path
            notify %Q|REMOVED: #{file_path}|
          rescue => error
            $stderr.puts error
          end
        end
      end
    ensure
      FileUtils.touch exit_time_file
    end
  end

  private

  def exit_time
    @exittime ||= File.mtime(exit_time_file)
  end

  def exit_time_file
    File.expand_path('../../exittime', @db.db_dir)
  end

  def catch_up
    @directories.each do |dir|
      Dir["#{dir}/**/*.epub"].each do |file_path|
        next if File.file? exit_time_file and File.mtime(file_path) < exit_time
        begin
          removed = @db.remove file_path rescue nil
          @db.add file_path
          operation = removed ? 'MODIFIED' : 'ADDED'
          notify "#{operation}: #{file_path}"
        rescue => error
          $stderr.puts error
        end
      end
    end
  end

  def notify(message)
    $stderr.puts message
    `notify-send #{$PROGRAM_NAME} #{message.shellescape}` unless `which notify-send`.empty?
    `terminal-notifier -title #{$PROGRAM_NAME.shellescape} -message #{message.shellescape}` unless `which terminal-notifier`.empty?
  end
end
