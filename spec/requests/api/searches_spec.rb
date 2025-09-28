require 'rails_helper'

RSpec.describe 'Api::Searches', type: :request do
  let(:valid_params) do
    {
      location_id: '123',
      check_in: '2024-01-15',
      check_out: '2024-01-20',
      adults: '2',
      children: '1'
    }
  end
  let(:mock_results) { { 'hotels' => [{ 'name' => 'Test Hotel', 'price' => 100 }] } }

  describe 'GET /api/search' do
    context 'with valid parameters' do
      before do
        allow(External::Hotels).to receive(:search).and_return(mock_results)
      end

      it 'returns search results' do
        get '/api/search', params: valid_params
        
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)).to eq(mock_results)
      end
    end

    context 'with missing required parameters' do
      it 'returns validation error for missing location_id' do
        params = valid_params.except(:location_id)
        get '/api/search', params: params
        
        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)['error']['message']).to include('location_id is required')
      end

      it 'returns validation error for missing check_in' do
        params = valid_params.except(:check_in)
        get '/api/search', params: params
        
        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)['error']['message']).to include('check_in is required')
      end

      it 'returns validation error for missing check_out' do
        params = valid_params.except(:check_out)
        get '/api/search', params: params
        
        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)['error']['message']).to include('check_out is required')
      end

      it 'returns validation error for adults less than 1' do
        params = valid_params.merge(adults: '0')
        get '/api/search', params: params
        
        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)['error']['message']).to include('adults must be at least 1')
      end
    end

    context 'with invalid dates' do
      it 'returns validation error when check_out is before check_in' do
        params = valid_params.merge(
          check_in: '2024-01-20',
          check_out: '2024-01-15'
        )
        get '/api/search', params: params
        
        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)['error']['message']).to include('check_out must be after check_in')
      end

      it 'returns validation error for stay longer than 60 days' do
        params = valid_params.merge(
          check_in: '2024-01-01',
          check_out: '2024-03-15'
        )
        get '/api/search', params: params
        
        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)['error']['message']).to include('stay duration cannot exceed 60 days')
      end

      it 'returns validation error for invalid date format' do
        params = valid_params.merge(check_in: 'invalid-date')
        get '/api/search', params: params
        
        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)['error']['message']).to include('invalid date format')
      end
    end

    context 'with external API error' do
      before do
        allow(External::Hotels).to receive(:search)
          .and_raise(External::Hotels::Error.new('API Error'))
      end

      it 'returns gateway error' do
        get '/api/search', params: valid_params
        
        expect(response).to have_http_status(:bad_gateway)
        expect(JSON.parse(response.body)).to include('error')
      end
    end
  end
end

