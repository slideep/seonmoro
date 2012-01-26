# app/lastminute.rb

begin
  require 'mongo'
  require 'logger'
  require 'tempfile'
  require 'gettext'
  require 'digest/md5'
  require 'ostruct'

  require File.dirname(__FILE__) + '/../lib/lastminute_error'
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
      COL_DEPARTURE_DATE = 'Lahto'
      COL_DEPARTURE_CITY = 'Lahtopaikka'
      COL_COST = 'Hinta'

      attr_accessor :collection_name
      attr_accessor :collection

      # Connect to the give host, port and named database.
      # @param host [Object]
      # @param port [Object]
      # @param db_name [Object]
      # @return [Object]
      def connect(host, port = 29287, db_name = "seonmoro")
        if host == nil
          raise ArgumentError, 'A hostname has to be provided.'
        end
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
      def initialize(db, collection_name, index_name = nil)
        if db == nil
          raise ArgumentError, 'A database cannot be nil.'
        end
        if collection_name.length == 0
          raise ArgumentError, 'A valid name for the collection has to be provided.'
        end

        @db = db
        @collection_name = collection_name
        @collection = @db[collection_name]

        previous_sync = last_update
        current_sync = Time.now.to_i

        if previous_sync <= current_sync
          # TODO: päivitysrutiini tähän => haetaan ensimmäisen dokkarin päiväyksen jälkeiset
          #@collection.remove
        end

        if index_name != nil
          @collection.create_index index_name
        end
      end

      # @return [Time]
      def last_update
        updated_on_key = "UpdatedOn"
        begin
          doc = @collection.find_one
          return doc[updated_on_key] if (doc != nil)
        end if @collection != nil
      end

      # @param earliest [String]
      # @param cost [Integer]
      # @return [OpenStruct]
      def find_deals(earliest, cost = nil)
        deals = {}

        response = OpenStruct.new
        cursor = @collection.find({"Lahto" => {"$gte" => earliest}, "Hinta" => {"$lte" => cost}})
        cursor.each do |doc|

          response.lahto = doc[COL_DEPARTURE_DATE]
          response.hinta = doc["Hinta"]
          response.lisatty = doc["Lisatty"]
          response.matkakohde = doc["Matkakohde"]
          response.lahtopaikka = doc[COL_DEPARTURE_CITY]
          response.kesto = doc["Kesto"]
          response.varauslinkki = doc["Varauslinkki"]

          deals << response
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
        @collection.find do |cursor|
          cursor.each do |doc|
            yield doc
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