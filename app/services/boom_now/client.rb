class BoomNow::Client
  include Singleton

  class Error < StandardError; end
  class TimeoutError < Error; end
  class AuthenticationError < Error; end
  class NotFoundError < Error; end

  attr_accessor :token, :connection,  :skip_auth_header

  def initialize
    fetch_auth_token
    @skip_auth_header = false
  end

  def get(path, params = {})
    url = "#{BoomNowApi::BASE_URL}#{path}"
    Rails.logger.debug "-- GET API request to #{url}, using params: #{params}"

    response = connection.get(url, params)
    handle_response(response)
  rescue Faraday::TimeoutError => e
    raise TimeoutError, "Request timed out: #{e.message}"
  rescue Faraday::ConnectionFailed => e
    raise Error, "Connection failed: #{e.message}"
  end

  def post(path, params = {})
    url = "#{BoomNowApi::BASE_URL}#{path}"
    Rails.logger.debug "-- POST API request to #{url}, using params: #{params}"
    response = connection.post(url, params.to_json)
    handle_response(response)
  rescue Faraday::TimeoutError => e
    raise TimeoutError, "Request timed out: #{e.message}"
  rescue Faraday::ConnectionFailed => e
    raise Error, "Connection failed: #{e.message}"
  end

private

  def connection
      @connection ||=
        Faraday.new(url: BoomNowApi::BASE_URL,  headers: ) do |conn|
          conn.request :json
          conn.response :json
          conn.adapter Faraday.default_adapter
          conn.options.timeout = 60 #seconds
        end
  end

  def token(refresh: false)
    cache_key = "boom_api_client_access_token"
    access_token = Rails.cache.fetch(cache_key, expires_in: 1.month) { fetch_auth_token }
    
    @token && !refresh ? access_token  : fetch_auth_token
  end

  def fetch_auth_token
    @skip_auth_header = true # flag used to share the headers for different requests
    payload = {client_id: ::BoomNowApi::CLIENT_ID, client_secret: ::BoomNowApi::CLIENT_SECRET}
    body = post('/auth/token', payload)
    @skip_auth_header = false
    @connection = nil # reset to refresh headers
    @token = body["access_token"]
  end

  def handle_response(response)
    Rails.logger.debug "-- API response status: #{response.status}"
    Rails.logger.debug "-- API response body: #{response.body}"
    Rails.logger.debug "\n"

    case response.status
    when 200..299
      response.body
    when 401
      raise AuthenticationError, 'Invalid credentials'
    when 404
      raise NotFoundError, 'Resource not found'
    when 400..499
      raise Error, "Client error: #{response.status} - #{response.body}"
    when 500..599
      raise Error, "Server error: #{response.status} - #{response.body}"
    else
      raise Error, "Unexpected response: #{response.status} - #{response.body}"
    end
  end

  def headers
    out = {
        'Content-Type' => 'application/json',
        'Accept' => 'application/json'
      }
    out['Authorization'] = auth_header unless @skip_auth_header
    out
  end

  def auth_header
    "Bearer #{@token}"
  end
end



