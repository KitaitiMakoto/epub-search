class Add
  def initialize(db_dir, file_path)
    @file_path = Pathname.new(file_path)
    raise "File not readable: #{@file_path}" unless @file_path.readable?
    @db = EPUB::Search::Database.new(db_dir)
  end

  def run(update=true)
    @db.remove @file_path if update
    @db.add @file_path
  end
end
