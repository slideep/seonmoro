# apollomatkat_scraper.rb

begin
  require 'rubygems'
  require 'net/http'
  require 'uri'
  require 'hpricot'
  require 'yaml'
  require 'open-uri'

  require File.dirname(__FILE__) + '/../lib/scraper_base'
end

class ApollomatkatScraper < ScraperBase
  
end