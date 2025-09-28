require 'rails_helper'

RSpec.describe 'Api::Locations', type: :request do
  describe 'GET /api/locations' do
    context 'with valid query' do
      let(:mock_locations) do
        [
          { 'id' => '1', 'name' => 'New York', 'country' => 'USA' },
          { 'id' => '2', 'name' => 'New Orleans', 'country' => 'USA' }
        ]
      end

      before do
        allow(External::Locations).to receive(:search).with('New York').and_return(mock_locations)
      end

      it 'returns location suggestions' do
        get '/api/locations', params: { q: 'New York' }
        
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)).to eq(mock_locations)
      end
    end

    context 'with invalid query' do
      it 'returns validation error for empty query' do
        get '/api/locations', params: { q: '' }
        
        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)).to include('error')
      end

      it 'returns validation error for query too short' do
        get '/api/locations', params: { q: 'a' }
        
        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)).to include('error')
      end
    end

    context 'with external API error' do
      before do
        allow(External::Locations).to receive(:search)
          .and_raise(External::Locations::Error.new('API Error'))
      end

      it 'returns gateway error' do
        get '/api/locations', params: { q: 'New York' }
        
        expect(response).to have_http_status(:bad_gateway)
        expect(JSON.parse(response.body)).to include('error')
      end
    end
  end
end

