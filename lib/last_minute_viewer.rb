require 'mongo'
require 'sinatra'
require 'compass'
require 'sass'

use Rack::Session::Pool, :expire_after => 2592000

DB_HOST = 'ds029287.mongolab.com'
DB_PORT = 29287
DB_NAME = 'seonmoro'
DB_COL_NAME = 'seonmoro'

MUNICIPALITY_KEY = 'municipality'
AIRPORT_TYPE_KEY = "type"
AIRPORT_TYPE_LARGE_KEY = "large_airport"
AIRPORT_TYPE_MEDIUM_KEY = "medium_airport"
AIRPORT_ORIGIN_CITY = "Lahtopaikka"
AIRPORT_ORIGIN_COUNTRY = "iso_country"
COUNTRY_CODE = "code"

configure do

  Compass.configuration do |config|
    config.project_path = File.dirname(__FILE__)
    config.sass_dir = 'views'
  end

  set :app_file, __FILE__
  set :root, File.dirname(__FILE__)
  set :views, 'views'
  set :public_folder, 'public'
  set :haml, { :format => :html5 }
  set :sass, Compass.sass_engine_options

  db = Mongo::Connection.new['seonmoro']

  TRIPS = db['napsu']
  AIRPORTS = db['airports']
  DESTINATIONS = db['matkakohteet']
  COUNTRIES = db['countries']

end

get '/' do
  selector = {}
  @trips = TRIPS.find(selector).sort(["Hinta", -1]).limit(20)
  unless @trips.nil?
    @last_minute_count = @trips.collection.count
  end

  haml :last_minute_deals
end

get '/akkilahdot/:lahtopaikka' do |origin|
  @last_minute_airport = origin.capitalize

  fetch_trips(origin)

  haml :last_minute_deals
end

get '/akkilahdot/:lahtopaikka/rss' do |origin|
  @last_minute_airport = origin.capitalize
end

get '/akkilahdot/halytys' do
  haml :fare-alert
end

get '/rekisteroi' do
  haml :register
end

# create reservation link
def create_href(link)
  "<a href=\"#{link}\" rel=\"nofollow\" target=\"_blank\"> <strong>&raquo; Varaa</strong></a>"
end

# fetch details by origin airport (by default only Wikipedia entry's link)
def fetch_origin_country(airport)
  unless airport.nil?
      COUNTRIES.find({COUNTRY_CODE => airport[AIRPORT_ORIGIN_COUNTRY]}, :fields => ["wikipedia_link"]).each do |country|
        @wikipedia_link = country['wikipedia_link']
      end
  end
end

# fetch trips by origin airport (by default only medium type airports in Finland)
def fetch_trips(origin_city)
  return if origin_city.nil?

  airport_type = AIRPORT_TYPE_MEDIUM_KEY

  case
    when origin_city.downcase == 'helsinki'
      # Helsinki-Vantaa on ainoa poikkeus!
      airport_type = AIRPORT_TYPE_LARGE_KEY
  end

  # Suomesta tapahtuvien lähtöjen lentokentät ovat pääsääntöisesti medium-luokkaa.
  journey_airports = AIRPORTS.find({MUNICIPALITY_KEY => origin_city.capitalize, AIRPORT_TYPE_KEY => airport_type})
  unless journey_airports.nil?
    journey_airports.each do |airport|

      fetch_origin_country(airport)

      @trips = TRIPS.find({AIRPORT_ORIGIN_CITY => airport[MUNICIPALITY_KEY]})
    end
  end

  #@wikipedia_link = COUNTRIES.find(

end

# fetch trip destinations
def fetch_destinations
  @destinations = DESTINATIONS.find
end
