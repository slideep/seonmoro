# app/app.rb

require 'rubygems'
require 'logger'
require 'yaml'

require File.dirname(__FILE__) + '/../lib/lastminute'
require File.dirname(__FILE__) + '/../lib/scraper_base'

$LOG = Logger.new($stdout)

$running = true
Signal.trap('TERM') { $running = false }

class LastMinuteApp

  attr_reader :host, :port, :is_authenticated, :db, :db_name

  def initialize(&block)
    block.call if block
  end

  def load_configuration
    conf_file = File.dirname(__FILE__) + '/../config/env.yml'
    if File.exist?(conf_file)
      $LOG.info("Loading conf #{conf_file}")
      env = YAML.load_file(conf_file)
      unless env == nil
        env['database'].each_pair do |key, val|
          case key
            when 'host'
              $LOG.info("Host is going to be: #{val}")
              @host = val
            when 'port'
              $LOG.info("Port is going to be: #{val}")
              @port = val
            when 'db'
              $LOG.info("Database we're going to use is: #{val}")
              @db_name = val
            when 'username'
              $LOG.info("Username is #{val}")
              @username = val
          end
        end
      end
    end
  end

  def authenticate(host, port, db_name)
    @db = Mongo::Connection.new(host, port).db(db_name)
    if @db != nil
      @is_authenticated = @db.authenticate('seonmoro', 'seonmoro')
    end
  end

  def process(db, db_col_name, is_authenticated)
    if is_authenticated
      lastminute_collection = db.collection(db_col_name)
      if lastminute_collection != nil && lastminute_collection.count > 0
        $LOG.info("#{db_col_name} has #{lastminute_collection.count} documents.")
        lm = LastMinute::Storage::MongoDB.new(db, db_col_name, :seonmoro)
        if lm != nil
          last_update = Time.at(lm.fetch_last_update)
          $LOG.info("#{db_col_name} was last updated on #{last_update}")
        end
      end
    end
  end
end