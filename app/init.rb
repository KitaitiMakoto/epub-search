class Init
  def initialize(db_dir)
    @db = EPUB::Search::Database.new(db_dir)
  end

  def run(force=false)
    $stderr.puts "create database #{@db.db_file}"
    @db.create force
  end
end
