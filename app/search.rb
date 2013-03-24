class Search
  def initialize(db_dir, search_word)
    @word = search_word
    @db = EPUB::Search::Database.new(db_dir)
  end

  def run
    re = /#{Regexp.escape(@word)}/o
    hl = HighLine.new if $stdout.tty?
    books = Hash.new {|h, iri|
      h[iri] = EPUB::Parser.parse(iri)
    }
    @db.search @word do |result|
      result.each_pair do |location, records|
        puts "#{records.first.title}(#{location})"
        book = books[location]
        records.each do |record|
          item = book.manifest.items.find {|i| i.href.to_s == record.iri}
          doc = Nokogiri.XML(item.read)
          title = doc.search('title').first.text
          record.content.each_line do |line|
            if line =~ re
              result = "  [#{title}(#{record.iri})]: #{line}"
              result.gsub!(re, hl.color(@word, :red, :bold)) if $stdout.tty?
              puts result
            end
          end
        end
      end
    end
  end
end
