var MongoProvider = require('../DAL/MongoProvider.js').MongoProvider;

exports["Get all orders"] = function(test)
{
	console.log("this is a first test run..");

	var provider = new MongoProvider();

	provider.getAirports(function(airports){
		
		console.log("callback called from getAirports");
		for(var i=0; i<airports.length; i++)
		{
			console.log(i + " --> " + airports[i]);
		}

	test.done();
	});

	// console.log("Ending test");
}