class BoomNow::Hotels
  class Error < StandardError; end

  def self.search(params)
    client = BoomNow::Client.new
    results = client.get('/listings', params)
    results["listings"]
  rescue BoomNow::Client::Error => e
    raise Error, "Failed to search hotels: #{e.message}"
  end
end
