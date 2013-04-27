module EPUB
  module Search
    class Database
      class Actor
        include Celluloid

        def initialize(db)
          @db = db
        end

        def add(file_path)
          @db.add file_path
        end

        def remove(file_path)
          @db.remove file_path
        end

        def update(file_path)
          @db.remove file_path
          @db.add file_path
        end
      end
    end
  end
end
