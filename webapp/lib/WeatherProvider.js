// wunderground.com
// KeyId: 1fdfc4cebef8f7aa
// http://api.wunderground.com/api/KEY/FEATURE/[FEATURE…]/q/QUERY.FORMAT

// Example:
// http://api.wunderground.com/api/1fdfc4cebef8f7aa/forecast/q/Finland/Helsinki.json

var http = require("http");

function WeatherProvider()
{
	
}

WeatherProvider.prototype.GetForecast(filter, callback)
{
	var options = {
	    host: 'api.wunderground.com',
	    path: '/api/1fdfc4cebef8f7aa/forecast/' + filter + '.json'
	    // path: '/api/1fdfc4cebef8f7aa/forecast/q/Finland/Helsinki.json'
	};

	http.get(options, function (http_res) {
	    // initialize the container for our data
	    var data = "";

	    // this event fires many times, each time collecting another piece of the response
	    http_res.on("data", function (chunk) {
	        // append this chunk to our growing `data` var
	        data += chunk;
	    });

	    // this event fires *one* time, after all the `data` events/chunks have been gathered
	    http_res.on("end", function () {
	        // you can use res.send instead of console.log to output via express
	        callback(data);
	    });
	});	
}

export.WeatherProvider = weatherProvider;