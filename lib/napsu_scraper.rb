# napsu_scraper.rb

begin
  require 'net/http'
  require 'uri'
  require 'hpricot'
  require 'open-uri'

  require File.dirname(__FILE__) + '/../lib/scraper_base'
end

class NapsuScraper < ScraperBase
  def scrape(url)
    raise ArgumentError, t('scraper_url_missing') if url == nil
    begin
      register_scraper(url) unless (url =~ URI::regexp).nil?
      doc = open_scraper
      unless doc.nil?
        rows = []

        (doc/"table//tr").each do |row|
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

          rows << cells
        end
      end
    end
  end
end

napsu_url = 'C:\tmp\napsu-akkilahdot.html'
napsu = NapsuScraper.new(napsu_url)
napsu.scrape(napsu_url)