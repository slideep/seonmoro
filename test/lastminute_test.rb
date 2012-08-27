  # test/lastminute_test.rb

  require File.dirname(__FILE__) + '/../lib/lastminute'
  require File.dirname(__FILE__) + '/../lib/last_minute_parse'
  require File.dirname(__FILE__) + '/../lib/last_minute_worker'
  require File.dirname(__FILE__) + '/../lib/napsu_scraper'

  require 'test/unit'
  
  class LastMinuteTest < Test::Unit::TestCase

    DB_HOST = "ds029287.mongolab.com"
    DB_PORT = 29287
    DB_NAME = "seonmoro"
    DB_COL_NAME = "seonmoro"
    
    # Setup - create a new connection and initializes an instance
    def setup
      @page_number = 1
      @start_date = Time.now.strftime('%d.%m.%Y')
      @napsu_url = "http://www.napsu.fi/Includefiles/Matkailu/akkilahdot2.php?sd=#{@start_date}as=2&order=pvm&ascdesc=asc&p=#{@page_number}"

      @db = Mongo::Connection.new(DB_HOST, DB_PORT).db(DB_NAME)
      is_authenticated = @db.authenticate(DB_NAME, DB_NAME)
      if is_authenticated
        @lm = LastMinute::Storage::MongoDB.new(@db, DB_COL_NAME, DB_NAME)
      end
     
      @napsu_scraper = NapsuScraper.new(@napsu_url)
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

      results = []

      1.times.each do |i|
        @page_number += i

        @last_minute_deals = @napsu_scraper.scrape(create_url @page_number)
        unless @last_minute_deals.nil? && @last_minute_deals.length > 0
          @last_minute_deals.each { |deal| results << deal }
        end

      end

      assert_equal 20, results.length

    end

    def create_url page_number
      "http://www.napsu.fi/Includefiles/Matkailu/akkilahdot2.php?sd=#{@start_date}as=2&order=pvm&ascdesc=asc&p=#{page_number}"
    end
  end