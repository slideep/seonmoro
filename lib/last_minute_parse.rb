
# This module contains matchers to extract information out of scraped resource.
module LastMinuteParse

  # Regex's for parsing request (either scraping or tweet)
  PARSE_TRIP_FROM = /^[a-zA-Z]+$/
  PARSE_TRIP_DATE = /^([123]?([1-3][0-9]){1,2}.\d\d?.?|\d?\d.\d\d?)$/i
  PARSE_TRIP_DAY_OF_WEEK = /^(ma|ti|ke|to|pe|la|su)-?(ma|ti|ke|to|pe|la|su)*$/i
  PARSE_TRIP_MONTH = /^(tammi|helmi|maalis|huhti|touko|kesa|heina|elo|syys|loka|marras|joulu)-?(tammi|helmi|maalis|huhti|touko|kesa|heina|elo|syys|loka|marras|joulu)*$/i
  PARSE_TRIP_DURATION = /^\d*(vkoa|vko|pv)$/i
  PARSE_TRIP_ADDED = /^(<|>) [\d]*(h|vrk)$/i
  PARSE_TRIP_COST = /([+-]?[0-9]+)/i

end