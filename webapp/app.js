
/**
 * Module dependencies. x
 */

var express = require('express')
  , routes = require('./routes')
  , offerProvider = require('./lib/OfferProvider')

var app = module.exports = express.createServer();

// Configuration

app.configure(function(){
  app.set('views', __dirname + '/views');
  app.set('view engine', 'jade');
  app.use(express.bodyParser());
  app.use(express.methodOverride());
  app.use(express.cookieParser());
  app.use(express.session({ secret: 'your secret here' }));
  app.use(app.router);
  app.use(express.static(__dirname + '/public'));
});

app.configure('development', function(){
  app.use(express.errorHandler({ dumpExceptions: true, showStack: true })); 
});

app.configure('production', function(){
  app.use(express.errorHandler()); 
});

app.helpers({
  test: String("this_is_a_test_variable"),
  JSON: JSON,
  console: console
})

// Routes
app.get('/', routes.index);

app.get('/main', routes.main);

app.get('/offers.json', function(request, response){
  response.contentType('application/json');
  var provider = new OfferProvider();

  provider.GetOffers(function(result){
    response.send(result);
  });

});

app.listen(3000);
console.log("Express server listening on port %d in %s mode", app.address().port, app.settings.env);