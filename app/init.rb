class Init
  FILE_NAME = 'epub-search.db'
  def initialize(db_dir)
    @db_dir = Pathname.new(db_dir)
    @db_file = @db_dir + FILE_NAME
  end

  def run(force=false)
    $stderr.puts "create database #{@db_file}"
    EPUB::Search::Database.new(@db_dir).create(force)
  end
end
