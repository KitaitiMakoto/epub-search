class Search
  def initialize(db_dir, search_word)
    @word = search_word
    @db = EPUB::Search::Database.new(db_dir)
  end

  def run
    @db.search @word do |result|
      EPUB::Search::Formatter::CLI.new(result, @word).format
    end
  end
end
