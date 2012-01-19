# test/scraper_base_test.rb

require 'test/unit'
require 'last_minute'
require 'scraper_base'
require 'detur_scraper'
require 'yaml'

class ScraperBaseTest < Test::Unit::TestCase

  DB_NAME = "seonmoro"
  DB_COL_NAME = "detur"

  # Setup - create a new connection and initializes an instance
  def setup
    @db = Mongo::Connection.new("ds029287.mongolab.com", 29287).db(DB_NAME)

    is_authenticated = @db.authenticate(DB_NAME, DB_NAME)
    if is_authenticated
      @lm = LastMinute::Storage::MongoDB.new(@db, DB_COL_NAME, DB_NAME)

      conf_file = File.join(File.dirname(__FILE__), 'env.yml')
      if File.exist?(conf_file)
        env = YAML.load_file(File.join(File.dirname(__FILE__), 'env.yml'))
        env['database'].each_pair do |key, val|
          case key
            when 'host'
              puts "Host is going to be: #{val}"
            when 'port'
              puts "Port is going to be: #{val}"
            when 'db'
              puts "Database we're going to use is: #{val}"
            when 'username'
              puts "Username is #{val}"
            else
              # type code here
          end
        end unless env == nil
      end

      @detur_scraper = DeturScraper.new("http://www.detur.fi/themes/detur/LastMinutedetail.aspx")

    end
  end

  def test_scraper_is_registered
    assert.equal 1, @detur_scraper.registry.count > 0
  end

end