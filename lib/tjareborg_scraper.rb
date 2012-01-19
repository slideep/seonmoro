# tjareborg_scraper.rb

begin
  require 'rubygems'
  require 'net/http'
  require 'uri'
  require 'hpricot'
  require 'yaml'
  require 'open-uri'

  require File.dirname(__FILE__) + '/../lib/scraper_base'
end

class TjareborgScraper < ScraperBase
  def scrape(url)
    raise ArgumentError, t('scraper_url_missing') if url == nil
    begin
      register_scraper(url) unless (url =~ URI::regexp).nil?

      doc = open_scraper
      unless doc.nil?
        rows = []
        super.extract_cells(row)

        (doc/"table.LastMinuteDetails//tr").each do |row|

          # departure date
          departure_date = (row/:"td.Date").inner_text.chomp

          # destination img src
          destination_img_html = (row/:"td.Destination//div.Picture").inner_html
          unless destination_img_html.nil?
            destination_img = extract_destination_img(destination_img_html)
          end

          # destination
          destination_text = (row/:"td.Destination/div.HotelLocation").inner_text.strip.chomp
        end
      end
    end
  end
end