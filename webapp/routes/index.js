var offerProvider = require('../lib/OfferProvider');

/*
 * GET home page.
 */

exports.index = function(req, res){
  res.render('index', { title: 'Express', layout: true })
};

exports.main = function(req, res){
	var provider = new OfferProvider();
	provider.GetOffers(function(result){
		res.render('main', {offers: result, layout: true});
	});
};