class Server
  def initialize(dir)
    @db = EPUB::Search::Database.new(File.join(dir, EPUB::Search::Database::DIR_NAME))
  end

  def run
    Rack::Server.start :app => EPUB::Search::Server.new(@db), :Host => '127.0.0.1'
  end
end
