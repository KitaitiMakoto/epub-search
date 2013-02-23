class Remove
  def initialize(db_path, file_path)
    @db_path, @file_path = db_path, Pathname(file_path)
  end

  def run
    location = @file_path.expand_path.to_s
    Groonga::Database.open @db_path do
      records = Groonga['Pages'].select {|record|
        record.location == location
      }
      records.each do |record|
        record.key.delete
      end
    end
  end
end
