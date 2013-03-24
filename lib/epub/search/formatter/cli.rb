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
          @data.each_pair do |location, records|
            records.each do |record|
              record.content.each_line do |line|
                next unless line =~ re
                result = line.chomp
                result.gsub!(re, hilighter.color(@word, :red, :bold)) if hilight?
                result << "  [#{record.page_title}(#{record.book_title}): #{location} - #{record.iri}]"
                puts result
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
