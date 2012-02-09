# app/lastminute.rb

begin
  require 'active_support/core_ext/numeric/time'
  require 'logger'
  require 'digest/md5'
  require 'optparse'
  require 'chatterbot/dsl'
  require 'bitly'
  require 'ostruct'

  require File.dirname(__FILE__) + '/../lib/lastminute'
  require File.dirname(__FILE__) + '/../app/last_minute_app'
  require File.dirname(__FILE__) + '/../lib/scraper_base'
  require File.dirname(__FILE__) + '/../lib/last_minute_parse'

end

module LastMinute
  VERSION = "0.0.1"

  module Twitter

    # Date & time when the connection was created
    attr_reader :conn_created

    def initialize
      @conn_created = Time.now
    end

    def conn_age
      Time.now - @conn_created
    end

    # Ask the LastMinuteBot for last minute deals
    class LastMinuteBot
      extend LastMinuteParse

      # Set to true to enable debugging (on by default)
      attr_accessor :debug_mode

      # Bot's configuration options passed either from commandline
      attr_reader  :options

      def initialize(options = {})
        @options = options
        @options[:debug_mode] = true
        @debug_mode = true

        # last minute bot's options
        parse_options()
      end

      def parse_options
        opts = OptionParser.new do |opts|
          opts.banner = "Usage: #{File.basename($0)} [options] start|stop|restart|run"
          opts.on('-h', '--help', 'Show this message') do
            puts opts
            exit 1
          end
          opts.on('--debug=true|false', "Set to true to enable debugging (on by default)") do |n|
            @options[:debug_mode] = n
          end
          opts.on('--sleep-delay N', "Amount of time to sleep between replies") do |n|
            @options[:sleep_delay] = n
          end
          opts.on('--log-dir=DIR', "Specifies an directory in which to store the log messages.") do |n|
            @options[:pid_dir] = n
          end
        end
      end

      # packet format:
      #
      #  -------------------------------------------------------------------
      #  from|earliest|cost(max)|destination
      #  -------------------------------------------------------------------
      #
      #  from        = e.g. helsinki or hel
      #  earliest    = dd.MM.yyyy or dd or dd.MM or dd.MM.
      #  cost        =
      #  destination =
      def parse_response(tweet)
        unless tweet.nil?

          # TODO: tämä on siis oikeasti request
          response = OpenStruct.new
          tweet[:text].strip.split(' ').each do |word|
            case
              when PARSE_TRIP_FROM =~ word
                response.from = $&.slice(0, 3)
              when PARSE_TRIP_DATE =~ word
                response.earliest = $&
              when PARSE_TRIP_COST =~ word
                response.cost = $&
              when PARSE_DAY_OF_WEEK =~ word
                response.day = $&
              when PARSE_MONTH =~ word
                response.month = $&
            end
          end

          @app = LastMinuteApp.new
          unless @app.is_authenticated
            @app.load_configuration
            @app.authenticate(@app.host, @app.port, @app.db_name)
            @app.process @app.db, 'napsu', @app.is_authenticated
          end

          # Pelkkä lento
          # &#228; => 'ä', &#246; => 'ö'
          # dep_city => "Helsinki", "Kuopio", "Tampere", "Oulu", "Vaasa"

          # Mistä? Hel => Helsin[gistä], kuo => Kuopio[sta]


          # TODO: parse_response_trip (response)

          response.reservation_url = "http://" # TODO: parse_response_url
          response.text = "#USER#, " + response.from + " - " + response.destination + response.earliest + ", " + response.cost + " e, " + response.reservation_url + " #seonmoro"

          response
        end
      end

      def process

        log_dir = @options[:log_dir]
        Dir.mkdir(log_dir) unless File.exists?(log_dir)

        loop do
          replies do |tweet|
            unless tweet[:text].nil?
              #@slideep Helsinki - Kenia => 24.01., 445 e, 2 vkoa, http://bit.ly/z0mDlL #seonmoro
              response = parse_response tweet
              reply response.text, tweet unless response.nil?
            end
          end

          update_config

          sleep 10
        end
      end

    end
  end
end