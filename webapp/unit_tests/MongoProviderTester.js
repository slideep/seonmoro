var offerProvider = require('../lib/OfferProvider').OfferProvider;


/*
	Test to ensure that offers are returned via the OfferProvider GetOffers method
*/
exports["Get offers successfully"] = function(test)
{
	var provider = new OfferProvider();

	provider.GetOffers(function(offers){
		test.expect(1);
		test.ok(offers.length > 0, "Number of offers: " + offers.length);

		var offer = offers[0];
		console.log(offer);

		test.done();
	});
}
