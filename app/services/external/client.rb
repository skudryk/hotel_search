class External::Client
  class Error < StandardError; end
  class TimeoutError < Error; end
  class AuthenticationError < Error; end
  class NotFoundError < Error; end

  attr_accessor :token

  def initialize
    @connection = Faraday.new(
      url: ExternalApi::BASE_URL,
      headers: {
        'Content-Type' => 'application/json',
        'Accept' => 'application/json',
        'Authorization' => auth_header
      }
    ) do |conn|
      conn.request :json
      conn.response :json
      conn.adapter Faraday.default_adapter
    end

    fetch_auth_token
  end

  def get(path, params = {})
    p "API request to #{ExternalApi::BASE_URL}#{path}, using params: #{params}"

    response = @connection.get(path, params)
    handle_response(response)
  rescue Faraday::TimeoutError => e
    raise TimeoutError, "Request timed out: #{e.message}"
  rescue Faraday::ConnectionFailed => e
    raise Error, "Connection failed: #{e.message}"
  end

  private

  def fetch_auth_token
    resp = get('/auth/token', {client_id: ExternalApi::CLIENT_ID, client_secret: ExternalApi::CLIENT_SECRET})
    # FIXME - got HTML response
    return nil unless resp.respond_to?(:status)

    case resp.status
    when 200..299
      @token = resp.body["token"]
    when 401
      raise AuthenticationError, 'Invalid credentials'
    end
  end
  
  def auth_header
    "Bearer #{@token}"
  end

  def handle_response(response)
    p "API response: #{response.status}"
    p "API response: #{response.body}"

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
end

