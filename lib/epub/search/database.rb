module EPUB
  module Search
    class Database
      FILE_NAME = 'epub-search.db'

      attr_reader :db_dir

      def initialize(db_dir)
        @db_dir = Pathname === db_dir ? db_dir : Pathname.new(db_dir)
        Groonga::Context.default_options = {:encoding => :utf8}
      end

      def db_file
        @db_file ||= @db_dir + FILE_NAME
      end

      def pages
        Groonga['Pages']
      end

      def init(force=false)
        @db_dir.rmtree if force
        @db_dir.mkpath
        Groonga::Database.create :path => db_file.to_path
        Groonga::Schema.create_table 'Pages', :type => :array
        Groonga::Schema.change_table 'Pages' do |table|
          table.text 'location' # file path or URI
          table.text 'iri' # inner IRI
          table.text 'book_title'
          table.text 'page_title'
          table.text 'metadata'
          table.text 'content'
        end
        Groonga::Schema.create_table 'Terms',
        :type => :patricia_trie,
        :normalizer => :NormalizerAuto,
        :default_tokenizer => 'TokenBigram'
        Groonga::Schema.change_table 'Terms' do |table|
          table.index 'Pages.book_title'
          table.index 'Pages.metadata'
          table.index 'Pages.content'
        end
      end

      # @return [Integer] the number of added recoreds
      def add(file_path)
        file_path = Pathname.new(file_path) unless file_path.kind_of? Pathname
        location = file_path.expand_path
        book = EPUB::Parser.parse(location)
        record_count = 0
        open do
          book.each_content do |content|
            next unless content.media_type == 'application/xhtml+xml'
            doc = Nokogiri.XML(content.read)
            page_title = doc.search('title').first.text
            body = Nokogiri.XML(doc.search('body').first.to_xml).content
            pages.add('location'   => location.to_s,
                      'iri'        => content.href.to_s,
                      'book_title' => book.title,
                      'page_title' => page_title,
                      'content'    => body)
            record_count += 1
          end
        end
        record_count
      end

      # @return [Integer] the number of removed recoreds
      def remove(file_path)
        file_path = Pathname.new(file_path) unless file_path.kind_of? Pathname
        location = file_path.expand_path.to_path
        record_count = 0
        open do
          records = pages.select {|record|
            record.location == location
          }
          records.each do |record|
            record.key.delete
            record_count += 1
          end
        end
        record_count
      end

      def search(word, book=nil)
        open do
          result = pages.select {|record|
            conditions = [record.content =~ word]
            conditions << (record.book_title =~ book) if book
            conditions
          }.group_by(&:location)
          yield result
        end
      end

      private

      def open
        Groonga::Database.open db_file.to_path do |database|
          yield database
        end
      end
    end
  end
end
