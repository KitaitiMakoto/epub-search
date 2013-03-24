module EPUB
  module Search
    class Database
      FILE_NAME = 'epub-search.db'

      def initialize(db_dir)
        @db_dir = Pathname.new(db_dir)
        Groonga::Context.default_options = {:encoding => :utf8}
      end

      def db_file
        @db_file ||= @db_dir + FILE_NAME
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
    end
  end
end
