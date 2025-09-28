class External::Hotels
  class Error < StandardError; end

  def self.search(params)
    cache_key = build_cache_key(params)
    
    Rails.cache.fetch(cache_key, expires_in: 30.minutes) do
      client = External::Client.new
      results = client.get('/listings', params)
      results["listings"]
    end
  rescue External::Client::Error => e
    raise Error, "Failed to search hotels: #{e.message}"
  end

  private

  def self.build_cache_key(params)
    normalized_params = normalize_params(params)
    "v1:search:#{normalized_params[:qd]}:" \
    "#{normalized_params[:check_in]}:#{normalized_params[:check_out]}:" \
    "a#{normalized_params[:quests][:adults]}:c#{normalized_params[:quests][:children]}"
  end
end
