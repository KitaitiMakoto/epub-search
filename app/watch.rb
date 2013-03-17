class Watch
  def initialize(db_path, directories)
    raise ArgumentError, 'specify at least one directory' if directories.empty?
    @db_path, @directories = db_path, directories
  end

  def run
    $PROGRAM_NAME = File.basename($PROGRAM_NAME)
    $stderr.puts 'start to watch:'
    @directories.each do |dir|
      $stderr.puts "  * #{dir}"
    end
    Listen.to *@directories, :filter => /\.epub\Z/ do |modified, added, removed|
      modified.each do |file_path|
        next unless file_path =~ /\.epub\Z/
        file_path.force_encoding 'UTF-8'
        begin
          Remove.new(@db_path, file_path).run
          Add.new(@db_path, file_path).run
          notify %Q|MODIFIED: #{file_path}|
        rescue => error
          $stderr.puts error
        end
      end
      added.each do |file_path|
        next unless file_path =~ /\.epub\Z/
        file_path.force_encoding 'UTF-8'
        begin
          Add.new(@db_path, file_path).run
          notify %Q|ADDED: #{file_path}|
        rescue => error
          $stderr.puts error
        end
      end
      removed.each do |file_path|
        next unless file_path =~ /\.epub\Z/
        file_path.force_encoding 'UTF-8'
        begin
          Remove.new(@db_path, file_path).run
          notify %Q|REMOVED: #{file_path}|
        rescue => error
          $stderr.puts error
        end
      end
    end
  end

  private

  def notify(message)
    $stderr.puts message
    `notify-send #{$PROGRAM_NAME} #{message.shellescape}` unless `which notify-send`.empty?
  end
end
