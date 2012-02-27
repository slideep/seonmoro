var Db = require('mongodb').Db;
var Connection = require('mongodb').Connection;
var Server = require('mongodb').Server;
var BSON = require('mongodb').BSON;
var ObjectID = require('mongodb').ObjectID;

MongoProvider = function() {
  console.log("Starting up a new db session");

  var host = 'localhost';
  var port = 27017;
  var databaseName = 'seonmoro';
  this.db = new Db(databaseName, new Server(host, port, {auto_reconnect: true}, {}));
  this.db.open(function(){});

  console.log('Database connection established successfully');
};


MongoProvider.prototype.getAirportsCollection = function(callback) {
  console.log("Enter:getAirportsCollection");
  
  // this.db.collection('airports', callback);
  this.db.collection('airports', function(error, airport_collection){
    db.find({}, function(err, cursor){
      cursor.forEach(function(err,doc){
        if(doc != null){
          console.log("iterating cursor...");
        }
      });
    });
    // callback(error, airport_collection);
  });

  console.log("Exit:getAirportsCollection");
};

MongoProvider.prototype.getAirports = function(callback) {
  console.log("Enter:getAirports");

  this.getAirportsCollection(function(error, collection){

    console.log("Enter: collection callback");
    debugger;
    collection.find().toArray(function(error, results){
      console.log("toArray callback");
      callback(results);
    });
    console.log("Exit: collection callback")

  });
  console.log("Exit:getAirports")
};

exports.MongoProvider = MongoProvider;