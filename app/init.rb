class Init
  DEFAULT_DB_PATH = File.join(Dir.home, '.epub-search/epub-search.db')
  def initialize(path=DEFAULT_DB_PATH)
    path = Pathname.new(path)
    if path.directory?
      @db_dir = path
      @db_file = @db_dir + 'epub-search.db'
    else
      @db_dir = path.dirname
      @db_file = path
    end
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
