var MongoProvider = require('../DAL/MongoProvider.js').MongoProvider;
var provider = new MongoProvider();

function test(airports){
	console.log("Enter:");
	console.log(arguments[0]);

	for(var i=0; i<airports.length; i++)
	{
		console.log(i + " --> " + airports[i]);
	}

}

provider.getAirports(test);
