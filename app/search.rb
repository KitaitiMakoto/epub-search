class Search
  def initialize(db_path, search_word)
    @db_path, @word = db_path, search_word
  end

  def run
    re = /#{Regexp.escape(@word)}/o
    hl = HighLine.new
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
