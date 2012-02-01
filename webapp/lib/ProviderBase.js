
/*!
	Base class for collection providers
*/


var mongodb = require('mongodb');
var server, db;

/**
	Constructor to initialize the database connection
*/

ProviderBase = function(){
	var host = 'localhost';
	var port = 27017;
	var databaseName = 'seonmoro';

	server = new mongodb.Server(host, port, {auto_reconnect: true});
	db = new mongodb.Db(databaseName, server, {});

}

/**
	Function for getting a handle on a desired collection

	Takes in the name of the collection and a callback function which further processes
	the collection

	@param {String} collectionName
	@param {Function} callback
*/

ProviderBase.prototype.GetCollection = function(collectionName, callback)
{
	db.open(function(error, db){
		if(error)
			throw Error("Failed to open database connection: " + error);
		else
		{
			db.collection(collectionName, function(error, collection){
				if(error)
					throw Error("Failed to get a handle on the provided collection: " + error);
				else
					callback(collection);
			});
		}
	});
}

exports.ProviderBase = ProviderBase;