require_relative 'helper'

class TestDatabase < EPUB::Search::TestCase
  def setup
    @dir = Dir.mktmpdir 'epub-search'
    @db = Database.new(@dir)
  end

  def teardown
    FileUtils.remove_entry_secure @dir if File.directory? @dir
  end

  def test_paths
    assert_equal Pathname.new(@dir), @db.db_dir
    assert_equal Pathname.new(@dir).join('epub-search.db'), @db.db_file
  end

  def test_init_make_db_paths
    dir = File.join(@dir, 'init')
    db = Database.new(dir)
    db.init
    assert_path_exist db.db_dir
    assert_path_exist db.db_file
  end

  class TestAfterInit < TestDatabase
    def setup
      super
      @db.init
    end

    def test_init_make_Pages_table
      open_db do
        assert_not_nil Groonga['Pages']
      end
    end

    def test_init_make_Terms_table
      open_db do
        assert_not_nil Groonga['Terms']
      end
    end

    class TestAdd < TestAfterInit
      class TestWhenNonEpubFilePassed < TestAdd
        def setup
          super
          @epub_path = __FILE__
        end

        def test_add_raise_error
          assert_raise Zip::Error do
            @db.add @epub_path
          end
        end
      end

      class TestWhenEpubFilePassed < TestAdd
        def setup
          super
          @epub_path = File.join(__dir__, 'rails_guides.epub')
        end

        def test_add_insert_records_same_to_xhtml_in_epub
          @db.add @epub_path
          epub = EPUB::Parser.parse(@epub_path)
          xhtmls = epub.each_content.select {|content| content.media_type == 'application/xhtml+xml'}.length
          open_db do
            assert_equal xhtmls, Groonga['Pages'].size
          end
        end
      end
    end
  end

  private

  def open_db
    Groonga::Database.open @db.db_file.to_path do |database|
      yield database
    end
  end
end
