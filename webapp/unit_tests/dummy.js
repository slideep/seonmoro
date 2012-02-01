// var MongoProvider = require('../DAL/MongoProvider.js').MongoProvider;
// var provider = new MongoProvider();

// function test(airports){
// 	console.log("Enter:");
// 	console.log(arguments[0]);

// 	for(var i=0; i<airports.length; i++)
// 	{
// 		console.log(i + " --> " + airports[i]);
// 	}

// }

// provider.getAirports(test);

// var mongo = require('mongodb');
// var db = new mongo.Db('seonmoro', new mongo.Server('localhost', 27017, {}), {});
// db.open(function(err, db) {
//   db.collection('airports', function(err, collection) {
// 	  collection.find({},function(err,cursor){
// 		  cursor.toArray(function(err,doc){
// 			  if(doc != null){
// 				  console.log(doc);
// 			  }
// 		  });
// 	  });
//   });
// });

// var mongodb = require('mongodb');
// var server = new mongodb.Server("localhost", 27017, {});
// new mongodb.Db('seonmoro', server, {}).open(function (error, client) {
//   if (error) throw error;
//   var collection = new mongodb.Collection(client, 'airports');
//   collection.find({}, {limit:10}).toArray(function(err, docs) {
//     console.dir(docs);
//   });
// });


// var mongodb = require('mongodb');
// var server = new mongodb.Server("localhost", 27017, {auto_reconnect: true});
// var db = new mongodb.Db('seonmoro', server, {});
// db.open(function (err, db) {
// 	db.collection('airports', function(err, cursor){
// 		cursor.find().toArray(function(err, doc){
// 			console.log(doc);
// 		});
// 	});
// });
  

var offerProvider = require('../lib/OfferProvider').OfferProvider;

var provider = new OfferProvider();
provider.GetOffers(function(offers){
	for(var i=0; i<offers.length; i++)
		console.log(offers[0]);
})
