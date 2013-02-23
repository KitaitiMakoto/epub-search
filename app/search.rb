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
      result = records.group_by {|record| record.location}
      result.each_pair do |location, records|
        puts records.first.title
        puts location
        records.each do |record|
          record.content.each_line do |line|
            puts "  [#{record.iri}]: #{line}" if line =~ /#{Regexp.escape(@word)}/
          end
        end
      end
    end
  end
end
