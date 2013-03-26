class Search
  def initialize(db_dir, search_word, book=nil)
    @word, @book = search_word, book
    @db = EPUB::Search::Database.new(db_dir)
  end

  def run(color=$stdout.tty?)
    highlight = [true, 'always'].include? color
    highlight = $stdout.tty? if color == 'auto'
    @db.search @word, @book do |result|
      EPUB::Search::Formatter::CLI.new(result, @word, highlight).format
    end
  end
end
