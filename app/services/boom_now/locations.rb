class BoomNow::Locations
  class Error < StandardError; end

  def self.search(query, page: 1)
      client = BoomNow::Client.instance
      results = client.get('/listings', { city: query, page: })
      
      results.is_a?(Hash) ? results["listings"] : []
  rescue BoomNow::Client::Error => e
    raise Error, "Failed to search locations: #{e.message}"
  end
end
