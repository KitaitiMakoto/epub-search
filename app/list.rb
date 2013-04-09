class List
  def initialize(dir)
    @db= EPUB::Search::Database.new(File.join(dir, EPUB::Search::Database::DIR_NAME))
  end

  def run(path=false)
    puts @db.books(path)
  end
end
