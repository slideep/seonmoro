# app/curl_worker.rb

require 'curl'
require 'open-uri'
require 'uri'
require 'net/http'
require 'logger'
require 'active_support'

$LOG = Logger.new($stdout)

class CurlWorker

  attr_reader = :has_to_cache, :cache_time
  attr_accessor = :cache_store, :feed_urls

  def initialize(urls, cache)
    @feed_urls = urls
    @has_to_cache = cache
    @cache_time = Time.now
  end

  def load_config_file(config_file)
    if !File.readable?(config_file)
      abort "Can not find config file at #{config_file}"
    end

  end

  def self.parse_feeds(feed_urls = nil)
    raise ArgumentError, t('feed_url_is_missing') if feed_urls.length == 0
    feed_urls.each_pair do |feed_name, feed_url|
      begin
        with_logging(feed_url) do
          feed = CURL.new({:has_to_cache => true})
          feed.save(feed_url, to_filename(feed_name))
        end if feed_url.start_with?("http")
      end
    end
  end

  def connect(feed_url)
    feed_url_uri = URI(feed_url)
  end

  def self.to_filename(feed_name)
    File.dirname(__FILE__) + '/../samples/' + feed_name.to_s unless feed_name.nil?
  end

  private

  def cache_file(file_name, cache_path)
    cache_time = File.ctime(file_name).localtime
    if File.exist?(file_name) && cache_time > Time.now - cache_time
      file_store = ActiveSupport::Cache.lookup_store(:file_store, cache_path)
    end if @has_to_cache
  end

  def with_logging(feed)
    begin
      $LOG.info("Fetching and saving feed #{feed} as a static file.")
      yield
      $LOG.info("Completed.")
    end
  end

end

# TODO: konffausfilusta feedien luku
feed_urls =
    {
        :hispania => 'http://fbook2.hispania.fi/sistaminuten.asp?AgentID',
        :apollomatkat => 'http://www.apollomatkat.fi/fi/tarjoukset/akkilahdot',
        :detur => 'http://www.detur.fi/themes/detur/LastMinutedetail.aspx',
        :aurinkomatkat => 'http://www.aurinkomatkat.fi/akkilahdot/',
        :tjareborg => 'http://www.tjareborg.fi/akkilahdot/',
        :finnmatkat => 'http://www.finnmatkat.fi/akkilahdot/',
        :lomamatkat => 'http://www.lomamatkat.fi/akkilahdot/'
    }

curl = CurlWorker.new(feed_urls, true)

CurlWorker.parse_feeds(feed_urls)
CurlWorker.cache_file(__FILE__, 'c:\\tmp', true)