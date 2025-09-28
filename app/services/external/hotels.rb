class External::Hotels
  class Error < StandardError; end

  EXPIRATION = 2.minutes.freeze

  def self.search(params)
    cache_key = build_cache_key(params)
    
    Rails.cache.fetch(cache_key, expires_in: EXPIRATION) do
      client = External::Client.new
      results = client.get('/listings', params)
      results["listings"]
    end
  rescue External::Client::Error => e
    raise Error, "Failed to search hotels: #{e.message}"
  end

  private

  def self.build_cache_key(params)
    "v1:search:#{params[:location_id]}:" \
    "#{params[:check_in]}:#{params[:check_out]}:" \
    "adults_#{params[:adults]}:children_#{params[:children]}"
  end
end
