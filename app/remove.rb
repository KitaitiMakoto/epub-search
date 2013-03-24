class Remove
  def initialize(db_dir, file_path)
    @file_path = Pathname(file_path)
    @db = EPUB::Search::Database.new(db_dir)
  end

  def run
    @db.remove @file_path
  end
end
