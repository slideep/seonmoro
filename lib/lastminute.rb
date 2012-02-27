# app/lastminute.rb

begin
  require 'mongo'
  require 'logger'
  require 'tempfile'
  require 'gettext'
  require 'digest/md5'
  require 'ostruct'
end

module LastMinute
  VERSION = "0.0.1"
  module Storage
    attr_reader :conn_created

    def initialize
      @conn_created = Time.now
    end

    # @return [Time]
    def conn_age
      Time.now - @conn_created  
    end
    
    # MongoDB database wrapper
    class MongoDB
      include GetText

      MAX_TRIES = 5

      # Constants for field names
      COL_SYNCDATE = 'syncdate'
      COL_ADDED = 'upddate'
      COL_DESTINATION = 'destination'
      COL_DESTINATION_COUNTRY = 'destcountry'
      COL_DESTINATION_CITY = 'destcity'
      COL_AGENCY = 'agency'
      COL_DEPARTURE_DATE = 'depdate'
      COL_DEPARTURE_COUNTRY = 'depcountry'
      COL_DEPARTURE_CITY = 'depcity'
      COL_COST = 'price'
      COL_DURATION = 'duration'
      COO_RESERVATION_URL = 'url'

      attr_accessor :collection_name
      attr_accessor :collection

      # Connect to the give host, port and named database.
      # @param host [Object]
      # @param port [Object]
      # @param db_name [Object]
      # @return [Object]
      def connect(host, port = 29287, db_name = "seonmoro")
        raise ArgumentError, 'A hostname has to be provided.' if host == nil
        tries = 0
        begin
          tries += 1
          @db = Mongo::Connection.new(host, port).db(db_name)
        rescue
          retry unless tries >= MAX_TRIES
        end

      end

      # Initialize a new instance of [MongoDB] class.
      # @param db [Object]
      # @param collection_name [Object]
      # @param index_name [Object]
      def initialize(db, collection_name = "seonmoro", index_name = nil)
        raise ArgumentError, 'A database cannot be nil.' if db == nil
        raise ArgumentError, 'A valid name for the collection has to be provided.' if collection_name.length == 0

        @db = db
        @collection_name = collection_name
        @collection = @db[collection_name]
        @collection.create_index index_name, :unique => true if index_name != nil
      end

      def sync_deals

        previous_sync = fetch_last_update
        current_sync = Time.now.to_i

        unless previous_sync.nil?
          if previous_sync <= current_sync
            # TODO: päivitysrutiini tähän => haetaan ensimmäisen dokkarin päiväyksen jälkeiset
            #@collection.remove
          end
        end
      end

      # @return [Time]
      def fetch_last_update
        begin
          doc = @collection.find_one
          return doc['syncdate'] if (doc != nil)
        end if @collection != nil
      end

      # @param deals [Hash]
      def add_deals(deals)
        unless deals.nil?
          deals.each { |deal| @collection.insert(deal, :safe => true) }
        end
      end

      # @param earliest [String]
      # @param cost [Integer]
      # @return [OpenStruct]
      def find_deals(earliest, cost = nil)
        deals = {}

        last_minute_deal = OpenStruct.new
        cursor = @collection.find({"Lahto" => {"$gte" => earliest}, "Hinta" => {"$lte" => cost}})
        cursor.each do |doc|

          last_minute_deal.depdate = doc[COL_DEPARTURE_DATE]
          last_minute_deal.price = doc[COL_COST]
          last_minute_deal.lisatty = doc[COL_ADDED]
          last_minute_deal.destination = doc[COL_DESTINATION]
          last_minute_deal.depcity = doc[COL_DEPARTURE_CITY]
          last_minute_deal.duration = doc[COL_DURATION]
          last_minute_deal.url = doc["Varauslinkki"]

          deals << last_minute_deal
        end

        deals
      end

      # Returns the size of the collection
      # @return [Integer]
      def size
        @collection.count
      end

      # Iterates over collection
      # @return [Object]
      def each
        unless @collection.nil?
          @collection.find do |cursor|
            cursor.each do |doc|
              yield doc
            end
          end
        end
      end

      # Closes the MongoDB connection if it's active.
      def close
        if @db.connection.active? && @db.connection
          @db.connection.close
        end
      end

    end
  end
end