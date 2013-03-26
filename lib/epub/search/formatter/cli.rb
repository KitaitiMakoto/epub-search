module EPUB
  module Search
    module Formatter
      class CLI
        def initialize(data, word, highlight=false)
          @data, @word, @highlight = data, word, highlight
        end

        def format
          word_re = /(?<word>#{Regexp.escape(@word)})/io
          highlighter = HighLine.Style(:red, :bold) if highlight?
          @data.each_pair do |location, records|
            records.each do |record|
              record.content.each_line do |line|
                next unless line =~ word_re
                result = line.chomp
                result.gsub! word_re, highlighter.color($~[:word]) if highlight?
                result << "  [#{record.page_title}(#{record.book_title}): #{location} - #{record.iri}]"
                puts result
              end
            end
          end
        end

        def highlight?
          @highlight
        end
      end
    end
  end
end
