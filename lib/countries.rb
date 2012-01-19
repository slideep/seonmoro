require 'mongo_mapper'

class Countries
  include MongoMapper::Document

end


MongoMapper.config = { 'host' => 'ds029287.mongolab.com', 'port' => 29287, 'database' => 'seonmoro', 'username' => 'seonmoro', 'password' => 'seonmoro'}

MongoMapper.connect

ct = Countries.new
