# scraper_base.rb

begin
  require 'net/http'
  require 'uri'
  require 'nokogiri'
  require 'hpricot'
  require 'yaml'
  require 'open-uri'

  require File.dirname(__FILE__) + '/../lib/scraper_utils'
  require File.dirname(__FILE__) + '/../lib/last_minute_parse'
end

# Base class for last minute deals scrapers
class ScraperBase
  extend LastMinuteParse

  # Periodic interval schedule (30 mins)
  UPDATE_SCHEDULE = 1800

  # URL for the scraper to use
  attr_reader :url

  # Hash of options for the last minute deal scraper
  attr_reader :opts

  # Registry for the domain/URL-pairs
  attr_reader :registry

  # Initialize and open connection
  # open web pages with UTF-8 encoding
  def open_scraper(url)
    URI === url ? Nokogiri::HTML::Document.parse(open(url), url.to_s, 'UTF-8') : url
  rescue OpenURI::HTTPError
    $stderr.puts "ERROR opening #{url}"
    Nokogiri('')
  end

  # Initialize the scraper with base URL and possible options.
  # @param url[String]
  def initialize(url)
    @url = url
  end

  # Finds a specified scraper for given URL's domain
  # @param url[String]
  def find_scraper(url)
    raise ArgumentError, t('scraper_url_missing_from_registry') if url == nil

    @registry.find { |url, scraper| url.include?(domain) }
  end

  # Registers given domain as a new scraper (with URL)
  def register_scraper(url)
    raise ArgumentError, t('scraper_domain_name_missing') if url == nil
   unless (url =~ URI::regexp).nil?
      # Correct URL, create registry if needed
      @registry ||= {}
      @registry[URI.parse(url).host] = self
    end

  end

  # Scrape specified URL's document
  def scrape(url)
  end

  # Parse given date into dd.MM.YYYY format
  def self.parse_date(date)
    unless date.nil?
      Date.strptime(date, '%d.%m.%Y')
    end
  end

  private

  # Finds links from the document
  # @param doc [String]
  def parse_links(doc)
    return if doc == nil
    doc = open_scraper
    unless doc.nil?
      links = doc.search("a[@href]")
      unless links.nil?
        links.each do |link|
          begin
            uri = URI.parse(link.attributes["href"])
          rescue
            # skip this link
          end if link.attributes["href"].length > 0
        end
      end
    end
  end

  # Extract row's cells
  def extract_cells(row)
    unless row.nil?
      cells = []
      (row/"td").each do |cell|
        if (cell/"").length > 0
          values = (cell).inner_html.split('<br />').collect do |str|
            pair = str.strip.split('=').collect { |val| val.strip }
            Hash[pair[0], pair[1]]
          end
          values.length == 1 ? cells << cell.inner_text : cells << values
        elsif cells << cell.inner_text
        end
      end
      cells
    end
  end
  
end
