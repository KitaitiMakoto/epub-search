class Remove
  def initialize(dir, file_path)
    @file_path = Pathname(file_path)
    @db = EPUB::Search::Database.new(File.join(dir, EPUB::Search::Database::DIR_NAME))
  end

  def run
    @db.remove @file_path
  end
end
