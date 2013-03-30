class Server
  def initialize(db_dir)
    @db = EPUB::Search::Database.new(db_dir)
  end

  def run
    Rack::Server.start :app => EPUB::Search::Server.new(@db), :Host => '127.0.0.1'
  end
end
