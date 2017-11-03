require "json"
require "http"
require "optparse"

class YelpApi

  # Place holders for Yelp Fusion's OAuth 2.0 credentials. Grab them
  # from https://www.yelp.com/developers/v3/manage_app
  @@client_id = "B64Cc6Q-c1EvvZ-1HiMnog"
  @@client_secret = "l1WV5TTTBjJA8qA5XqGpCB6Rxogbq0kToXTLDowaiGjep1WqUiq5qdJrFmAygUq7"


  # Constants, do not change these
  @@api_host = "https://api.yelp.com"
  @@search_path = "/v3/businesses/search"
  @@business_path = "/v3/businesses/"  # trailing / because we append the business id to the path
  @@token_path = "/oauth2/token"
  @@grant_type = "client_credentials"


  @@default_business_id = "yelp-san-francisco"
  @@default_term = "dinner"
  @@default_location = "San Francisco, CA"
  @@search_limit = 5

  # Make a request to the Fusion API token endpoint to get the access token.
  # 
  # host - the API's host
  # path - the oauth2 token path
  #
  # Examples
  #
  #   bearer_token
  #   # => "Bearer some_fake_access_token"
  #
  # Returns your access token
  def self.bearer_token
    # Put the url together
    url = "#{@@api_host}#{@@token_path}"

    raise "Please set your @@client_id" if @@client_id.nil?
    raise "Please set your @@client_secret" if @@client_secret.nil?

    # Build our params hash
    params = {
      client_id: @@client_id,
      client_secret: @@client_secret,
      grant_type: @@grant_type
    }

    response = HTTP.post(url, params: params)
    parsed = response.parse

    "#{parsed['token_type']} #{parsed['access_token']}"
  end


  # Make a request to the Fusion search endpoint. Full documentation is online at:
  # https://www.yelp.com/developers/documentation/v3/business_search
  #
  # term - search term used to find businesses
  # location - what geographic location the search should happen
  #
  # Examples
  #
  #   search("burrito", "san francisco")
  #   # => {
  #          "total": 1000000,
  #          "businesses": [
  #            "name": "El Farolito"
  #            ...
  #          ]
  #        }
  #
  #   search("sea food", "Seattle")
  #   # => {
  #          "total": 1432,
  #          "businesses": [
  #            "name": "Taylor Shellfish Farms"
  #            ...
  #          ]
  #        }
  #
  # Returns a parsed json object of the request
  def self.search(term, location)
    url = "#{@@api_host}#{@@search_path}"
    params = {
      term: term,
      location: location,
      limit: @@search_limit
    }

    response = HTTP.auth(bearer_token).get(url, params: params)
    response.parse
  end


  # Look up a business by a given business id. Full documentation is online at:
  # https://www.yelp.com/developers/documentation/v3/business
  # 
  # business_id - a string business id
  #
  # Examples
  # 
  #   business("yelp-san-francisco")
  #   # => {
  #          "name": "Yelp",
  #          "id": "yelp-san-francisco"
  #          ...
  #        }
  #
  # Returns a parsed json object of the request
  def self.business(business_id)
    url = "#{@@api_host}#{@@business_path}#{business_id}"

    response = HTTP.auth(bearer_token).get(url)
    response.parse
  end


  options = {}
  OptionParser.new do |opts|
    opts.banner = "Example usage: ruby sample.rb (search|lookup) [options]"

    opts.on("-tTERM", "--term=TERM", "Search term (for search)") do |term|
      options[:term] = term
    end

    opts.on("-lLOCATION", "--location=LOCATION", "Search location (for search)") do |location|
      options[:location] = location
    end

    opts.on("-bBUSINESS_ID", "--business-id=BUSINESS_ID", "Business id (for lookup)") do |id|
      options[:business_id] = id
    end

    opts.on("-h", "--help", "Prints this help") do
      puts opts
      exit
    end
  end.parse!


  command = ARGV


  case command.first
  when "search"
    term = options.fetch(:term, @@default_term)
    location = options.fetch(:location, @@default_location)

    raise "business_id is not a valid parameter for searching" if options.key?(:business_id)

    response = search(term, location)

    puts "Found #{response["total"]} businesses. Listing #{@@search_limit}:"
    response["businesses"].each {|biz| puts biz["name"]}
  when "lookup"
    business_id = options.fetch(:business_id, @@default_business_id)


    raise "term is not a valid parameter for lookup" if options.key?(:term)
    raise "location is not a valid parameter for lookup" if options.key?(:lookup)

    response = business(business_id)

    puts "Found business with id #{business_id}:"
    puts JSON.pretty_generate(response)
  else
    puts "Please specify a command: search or lookup"
  end

end