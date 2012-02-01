var providerBase = require('./ProviderBase').ProviderBase;
var config = require('./config').Config;

/**
	Constructor for OfferProvider
*/

OfferProvider = function(){
	console.log("Offer provider constructor");
	this.collectionName = config.collectionOffers;
};

OfferProvider.prototype.GetOffers = function(callback, filter) {
	debugger;
	if(!filter)
		filter = {};

	var base = new providerBase();
	base.GetCollection(this.collectionName, function(collection){
		collection.find().toArray(function(error, result){
			if(error)
				throw Error("Failed to create array from result: " + error);
			callback(result);
		});
	});
};

exports.OfferProvider = OfferProvider;