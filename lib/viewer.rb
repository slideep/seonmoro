require 'mongo'
require 'sinatra'

use Rack::Session::Pool, :expire_after => 2592000

MUNICIPALITY_KEY = "municipality"
AIRPORT_TYPE_KEY = "type"
AIRPORT_TYPE_LARGE_KEY = "large_airport"
AIRPORT_TYPE_MEDIUM_KEY = "medium_airport"
AIRPORT_ORIGIN_CITY = "Lahtopaikka"

configure do
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

  erb :matkakohteet
end

# create reservation link
def create_href(link)
  "<a href=\"#{link}\" rel=\"nofollow\" target=\"_blank\"> <strong>&raquo; Varaa</strong></a>"
end

# fetch trips by origin airport (by default only medium type airports in Finland)
def fetch_trips(origin)
  return if origin.nil?

  airport_type = AIRPORT_TYPE_MEDIUM_KEY

  case
    when origin.downcase == 'helsinki'
      # Helsinki-Vantaa on ainoa poikkeus!
      airport_type = AIRPORT_TYPE_LARGE_KEY
  end

  # Suomesta tapahtuvien lähtöjen lentokentät ovat pääsääntöisesti medium-luokkaa.
  journey_airports = AIRPORTS.find({MUNICIPALITY_KEY => origin.capitalize, AIRPORT_TYPE_KEY => airport_type})
  unless journey_airports.nil?
    journey_airports.each do |airport|
      @trips = TRIPS.find({AIRPORT_ORIGIN_CITY => airport[MUNICIPALITY_KEY]})
    end
  end

end

# fetch trip destinations
def fetch_destinations
  @destinations = DESTINATIONS.find
end

get '/akkilahdot/:lahtopaikka' do |origin|
  @last_minute_airport = origin.capitalize

  fetch_trips(origin)

  haml :matkakohteet
end