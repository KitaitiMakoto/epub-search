class Init
  def initialize(db_dir)
    @db = EPUB::Search::Database.new(db_dir)
  end

  def run(force=false)
    $stderr.puts "create database #{@db.db_file}"
    @db.init force
    if force
      exit_time_file = @db.db_dir.join('../exittime')
      exit_time_file.delete if exit_time_file.exist?
    end
  end
end
