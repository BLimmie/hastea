require "json"
require "http"
require "optparse"

API_KEY = ENV['YELP_API']

API_HOST = "https://api.yelp.com"
SEARCH_PATH = "/v3/businesses/search"
BUSINESS_PATH = "/v3/businesses/"  # trailing / because we append the business id to the path

DEFAULT_BUSINESS_ID = "yelp-san-francisco"
DEFAULT_TERM = "boba"
DEFAULT_LOCATION = "San Francisco, CA"
SEARCH_LIMIT = 5

def search(term, location)
    url = "#{API_HOST}#{SEARCH_PATH}"
    params = {
        term: term,
        location: location,
        limit: SEARCH_LIMIT
    }

    response = HTTP.auth("Bearer #{API_KEY}").get(url, params: params)
    response.parse
end

def business(business_id)
    url = "#{API_HOST}#{BUSINESS_PATH}#{business_id}"
  
    response = HTTP.auth("Bearer #{API_KEY}").get(url)
    response.parse
end