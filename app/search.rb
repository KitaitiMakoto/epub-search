class Search
  def initialize(db_path, search_word)
    @db_path, @word = db_path, search_word
  end

  def run
    Groonga::Database.open @db_path do
      pages = Groonga['Pages']

      records = pages.select {|record|
        record['content'] =~ @word
      }
      result = records.group_by(&:location)
      books = Hash.new {|h, iri|
        h[iri] = EPUB::Parser.parse(iri)
      }
      result.each_pair do |location, records|
        puts "#{records.first.title}(#{location})"
        book = books[location]
        records.each do |record|
          item = book.manifest.items.find {|i| i.href.to_s == record.iri}
          doc = Nokogiri.XML(item.read)
          title = doc.search('title').first.text
          record.content.each_line do |line|
            puts "  [#{title}(#{record.iri})]: #{line}" if line =~ /#{Regexp.escape(@word)}/
          end
        end
      end
    end
  end
end
