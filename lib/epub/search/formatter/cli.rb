module EPUB
  module Search
    module Formatter
      class CLI
        def initialize(data, word, hilight=$stderr.tty?)
          @data, @word, @hilight = data, word, hilight
        end

        def format
          re = /#{Regexp.escape(@word)}/o
          hilighter = HighLine.new if hilight?
          books = Hash.new {|h, iri| h[iri] = EPUB::Parser.parse(iri)}
          @data.each_pair do |location, records|
            book = books[location]
            records.each do |record|
              item = book.manifest.items.find {|i| i.href.to_s == record.iri}
              doc = Nokogiri.XML(item.read)
              page_title = doc.search('title').first.text
              record.content.each_line do |line|
                if line =~ re
                  result = line.chomp
                  result.gsub!(re, hilighter.color(@word, :red, :bold)) if hilight?
                  result << "  [#{page_title}(#{record.title}): #{location} - #{record.iri}]"
                  puts result
                end
              end
            end
          end
        end

        def hilight?
          @hilight
        end
      end
    end
  end
end
