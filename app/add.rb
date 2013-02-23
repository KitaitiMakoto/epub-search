class Add
  def initialize(db_path, file_path)
    raise "File not readable: #{file_path}" unless File.readable? file_path
    @db_path, @file_path = db_path, Pathname(file_path)
  end

  def run
    location = @file_path.expand_path
    book = EPUB::Parser.parse(location)
    Groonga::Database.open @db_path do
      pages = Groonga['Pages']

      book.each_content do |content|
        next unless content.media_type == 'application/xhtml+xml'
        pages.add('location' => location.to_s,
                  'iri'      => content.href.to_s,
                  'title'    => book.title,
                  'content'  => Nokogiri.HTML(content.read).search('body').first.content)
      end
    end
  end
end
