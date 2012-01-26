# napsu_scraper.rb

begin
  require 'date'
  require 'net/http'
  require 'uri'
  require 'hpricot'
  require 'open-uri'

  require File.dirname(__FILE__) + '/../lib/scraper_base'
end

class NapsuScraper < ScraperBase

  def initialize(url)
    begin
      unless url.nil?
        super.initialize(url)
      end
    rescue
      #
    end
  end

  def scrape(url)
    raise ArgumentError, t('scraper_url_missing') if url == nil
    begin
      register_scraper(url) unless (url =~ URI::regexp).nil?
      doc = open_scraper
      unless doc.nil?
        rows = []

        # skip 1st row
        curr_row_index = 0

        (doc/"table//tr").each do |row|

          curr_row_index += 1
          if curr_row_index == 1 && row[:id] == "tableheaders"
            break
          end

          cells = []

          # skip 6th cell
          curr_cell_index = 0


          (row/"td").each do |cell|
            if (cell/"").length > 0

              curr_cell_index += 1
              if curr_cell_index == 6
                break
              end

              cell_inner_text = (cell).inner_text.chomp

              # Lisätty
              if cell_inner_text =~ /^(<|>) [\d]*(h|vrk)$/i

              end

              # Lähtö
              if cell_inner_text =~ /^\d\d.\d\d.$/i

              end

              # Kesto
              if cell_inner_text =~ /^\d* (vkoa|vko|pv)$/i

              end

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


# test
def test_scrape(start_date)
  485.times do |page_number|
    page_number += 1
    napsu_url = "http://www.napsu.fi/Includefiles/Matkailu/akkilahdot2.php?sd=#{start_date}as=2&order=pvm&ascdesc=asc&p=#{page_number}"
    napsu = NapsuScraper.new(napsu_url)
    napsu.scrape(napsu_url)
  end
end

start_date = Time.now.strftime('%d.%m.%Y')
test_scrape(start_date)


