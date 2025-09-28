class External::Locations
  class Error < StandardError; end

    EXPIRATION = 1.hour.freeze

  def self.search(query)
    cache_key = "v1:locations:q:#{query.downcase.strip}"
    
    Rails.cache.fetch(cache_key, expires_in: EXPIRATION) do
      client = External::Client.new
      results = client.get('/listings', { city: query })
      
      results.is_a?(Hash) ? results["listings"] : []
    end
  rescue External::Client::Error => e
    raise Error, "Failed to search locations: #{e.message}"
  end
end
