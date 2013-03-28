require 'rack'

class Server
  def initialize(db_dir)
    @db = EPUB::Search::Database.new(db_dir)
  end

  def run
    Rack::Server.start :config => File.expand_path('../server.ru', __FILE__)
  end
end
