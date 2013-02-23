class Init
  FILE_NAME = 'epub-search.db'
  def initialize(db_dir)
    @db_dir = Pathname.new(db_dir)
    @db_file = @db_dir + FILE_NAME
  end

  def run
    $stderr.puts "create database #{@db_file}"
    @db_dir.mkpath
    Groonga::Context.default_options = {:encoding => :utf8}
    Groonga::Database.create(:path => @db_file.to_path)
    # key: path/to/epub-file
    Groonga::Schema.create_table 'Books', :type => :array
    Groonga::Schema.change_table 'Books' do |table|
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
      table.index 'Books.title'
      table.index 'Books.metadata'
      table.index 'Books.content'
    end
  end
end
