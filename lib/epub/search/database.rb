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
        @pages ||= Groonga['Pages']
      end

      def create(force=false)
        @db_dir.rmtree if force
        @db_dir.mkpath
        Groonga::Database.create(:path => db_file.to_path)
        Groonga::Schema.create_table 'Pages', :type => :array
        Groonga::Schema.change_table 'Pages' do |table|
          table.text 'location' # file path or URI
          table.text 'iri' # inner IRI
          table.text 'title'
          table.text 'metadata'
          table.text 'content'
        end
        Groonga::Schema.create_table 'Terms',
        :type => :patricia_trie,
        :normalizer => :NormalizerAuto,
        :default_tokenizer => 'TokenBigram'
        Groonga::Schema.change_table 'Terms' do |table|
          table.index 'Pages.title'
          table.index 'Pages.metadata'
          table.index 'Pages.content'
        end
      end

      def add(file_path)
        file_path = Pathname.new(file_path) unless file_path.kind_of? Pathname
        location = file_path.expand_path
        book = EPUB::Parser.parse(location)
        open do
          book.each_content do |content|
            next unless content.media_type == 'application/xhtml+xml'
            pages.add('location' => location.to_s,
                      'iri'      => content.href.to_s,
                      'title'    => book.title,
                      'content'  => Nokogiri.XML(Nokogiri.XML(content.read).search('body').first.to_xml).content)
          end
        end
      end

      def remove(file_path)
        location = file_path.expand_path.to_path
        open do
          records = pages.select {|record|
            record.location == location
          }
          records.each do |record|
            record.key.delete
          end
        end
      end

      def search(word)
        open do
          result = pages.select {|record| record['content'] =~ word}.group_by(&:location)
          yield result
        end
      end

      private

      def open
        return Groonga::Database.open(db_file.to_path) unless block_given?
        Groonga::Database.open db_file.to_path do |database|
          yield database
        end
        self
      end
    end
  end
end
