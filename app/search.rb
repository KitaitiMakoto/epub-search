class Search
  def initialize(db_dir, search_word)
    @word = search_word
    @db = EPUB::Search::Database.new(db_dir)
  end

  def run(color=$stdout.tty?)
    highlight = [true, 'always'].include? color
    highlight = $stdout.tty? if color == 'auto'
    @db.search @word do |result|
      EPUB::Search::Formatter::CLI.new(result, @word, highlight).format
    end
  end
end
