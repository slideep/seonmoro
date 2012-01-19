# lib/weather.rb

require 'uri'
require 'open-uri'
require 'net/http'
require 'rexml/document'

require File.dirname(__FILE__) + '/../lib/day'

class Weather
  attr_reader :location
  attr_reader :weather
  attr_reader :temp_c
  attr_reader :forecast_days
  attr_reader :now_icon
  attr_reader :now

  def initialize
    url = "http://api.wunderground.com/api/0400934ede582db5/geolookup/conditions/forecast/q/FI/Helsinki.xml"
    response = Net::HTTP.get_response(URI.parse(url)).body

    @now = REXML::Document.new(response)

    @now.elements.each('current_observation') do |curr|
      @location = curr.elements['display_location'].elements['full'].text
      @weather = curr.elements['weather'].text
      @temp_c = curr.elements['temp_c'].text
      @now_icon = curr.elements['icourl'].text
    end

    @forecast_days = []

    @now.elements.each('forecast') do |curr|
      curr.elements.each('txt_forecast/forecastday') do |day|
        @forecast_days << Day.new(day.elements['title'].text, day.elements['fcttext'].text, day.elements['icourl'].text)
      end
    end
  end
end

w = Weather.new
pp w.temp_c