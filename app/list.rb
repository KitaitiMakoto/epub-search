class List
  def initialize(db_dir)
    @db= EPUB::Search::Database.new(db_dir)
  end

  def run(path=false)
    puts @db.books(path)
  end
end
