# napsu_scraper.rb

begin
  require 'date'
  require 'net/http'
  require 'uri'
  require 'nokogiri'
  require 'open-uri'
  require 'ostruct'

  require File.dirname(__FILE__) + '/../lib/scraper_base'
  require File.dirname(__FILE__) + '/../lib/last_minute_parse'
end

class NapsuScraper < ScraperBase

  # Regex's for parsing request (either scraping or tweet)
  PARSE_TRIP_FROM = /^[a-zA-Z]+$/
  PARSE_TRIP_DATE = /^([123]?([1-3][0-9]){1,2}.\d\d?.?|\d?\d.\d\d?)$/i
  PARSE_TRIP_DAY_OF_WEEK = /^(ma|ti|ke|to|pe|la|su)-?(ma|ti|ke|to|pe|la|su)*$/i
  PARSE_TRIP_MONTH = /^(tammi|helmi|maalis|huhti|touko|kesa|heina|elo|syys|loka|marras|joulu)-?(tammi|helmi|maalis|huhti|touko|kesa|heina|elo|syys|loka|marras|joulu)*$/i
  PARSE_TRIP_DURATION = /^\d*(vkoa|vko|pv)$/i
  PARSE_TRIP_ADDED = /^(<|>) [\d]*(h|vrk)$/i
  PARSE_TRIP_COST = /([+-]?[0-9]+)/i

  #
  CSS_SELECTOR = "div#akkilahdotcontainer div#resultscontainer table tr[class=/"#{classname}/"]"

  def initialize(url)
    begin
      unless url.nil?
        super.initialize(url)
      end
    rescue
      #
    end
  end

  # @return [Array]
  def scrape(url)
    raise ArgumentError, t('scraper_url_missing') if url == nil
    begin

      last_minute_deals = []

      register_scraper(url) unless (url =~ URI::regexp).nil?

      scraper_document = open_scraper(url)

      unless scraper_document.nil?
        {:odd => "odd", :even => "even"}.each_pair do |classkey, classname|
          scraper_document.css(CSS_SELECTOR).collect do |row|

            last_minute_deal = OpenStruct.new

            # Synkattu
            last_minute_deal.syncdate = Time.now.to_i

            # Lisätty
            last_minute_deal.upddate = row.at("td[1]").text.strip

            # Lähtö
            last_minute_deal.depdate = row.at("td[2]").text.strip

            # Matkanjärjestäjä
            last_minute_deal.agency = row.at("td[3]").text.strip

            # Matkakohde
            destination = row.at("td[4]").text.strip.split(',')

            # Matkakohde
            last_minute_deal.destcity = destination[0]

            # Matkakohteen maa
            last_minute_deal.destcountry = destination[1]

            # Lähtöpaikka
            last_minute_deal.depcity = row.at("td[5]").text.strip

            # Hinta
            last_minute_deal.price = row.at("td[7]").text.strip

            # Kesto
            last_minute_deal.duration = row.at("td[8]").text.strip

            # Varauslinkki
            last_minute_deal.url = "http://" << URI.parse(url).host << row.at("td[9] a")[:href].strip

            last_minute_deals << last_minute_deal
          end
        end
      end

      last_minute_deals
    end
  end
end