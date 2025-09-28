# External API Configuration
module ExternalApi
  CLIENT_ID = ENV.fetch('CLIENT_ID', 'your_client_id_here')
  CLIENT_SECRET = ENV.fetch('CLIENT_SECRET', 'your_client_secret_here')
  BASE_URL = ENV.fetch('API_BASE_URL', 'https://api.example.com')
end

