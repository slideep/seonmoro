require "rspec"
require "mongo"
require 'last_minute'

describe LastMinute::Storage::MongoDB do

  DB_COL_NAME = "detur"

  before :each do

    @db = mock()

    @db = Mongo::Connection.new("ds029287.mongolab.com", 29287).db("seonmoro")
    is_authenticated = @db.authenticate("seonmoro", "seonmoro")
    @lm = LastMinute::Storage::MongoDB.new(@db, DB_COL_NAME, "seonmoro") if is_authenticated
  end

  it "should have a collection name that is expected" do
    @lm.collection_name.should == DB_COL_NAME
  end

  it "should have a matching collection count of documents" do
    @lm.collection.count.should == 21
  end

end