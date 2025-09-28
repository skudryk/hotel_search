class External::Locations
  class Error < StandardError; end

  def self.search(query)
    cache_key = "v1:locations:q:#{query.downcase.strip}"
    
    Rails.cache.fetch(cache_key, expires_in: 1.hours) do
      client = External::Client.new
      results = client.get('/listings/cities', { city: query })
      
      results.is_a?(Array) ? results : []
    end
  rescue External::Client::Error => e
    raise Error, "Failed to search locations: #{e.message}"
  end
end
