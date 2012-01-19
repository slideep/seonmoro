  # test/lastminute_test.rb
  
  require File.join(File.dirname(__FILE__), '..', 'lastminute')
  require File.join(File.dirname(__FILE__), '..', 'detur_scraper')
  
  require 'test/unit'
  
  class LastMinuteTest < Test::Unit::TestCase
    
    DB_NAME = "seonmoro"
    DB_COL_NAME = "detur"
    
    # Setup - create a new connection and initializes an instance
    def setup
      @db = Mongo::Connection.new("ds029287.mongolab.com", 29287).db(DB_NAME)
      is_authenticated = @db.authenticate(DB_NAME, DB_NAME)    
      if is_authenticated
        @lm = LastMinute::Storage::MongoDB.new(@db, DB_COL_NAME, DB_NAME) 
      end
     
      @detur_scraper = DeturScraper.new('http://www.detur.fi/themes/detur/LastMinutedetail.aspx') 
    end
     
    # Teardown
    def teardown
      @lm.close
    end
    
    # Test that collection's name is what's expected.
    def test_collection_name
      assert_equal DB_COL_NAME, @lm.collection_name
    end
    
    # Test that collection's count is what's expected.
    def test_collection_count
      assert_equal 21, @lm.collection.count
    end
    
    # Test that collection's size is what' expected.
    def test_collection_size
      assert_equal 21, @lm.size
    end
    
    def test_scraper_registered
      @detur_scraper.scrape(@detur_scraper.url)
    end
     
  end