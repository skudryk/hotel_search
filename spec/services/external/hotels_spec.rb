require 'rails_helper'

RSpec.describe External::Hotels do
  let(:mock_client) { instance_double(External::Client) }
  let(:search_params) do
    {
      location_id: '12',
      check_in: '2024-01-15',
      check_out: '2024-01-20',
      adults: 2,
      children: 1
    }
  end
  let(:sample_results) do
     {
       "listings":
         [
         {
            "id": "12",
            "title": "sample",
            "pictures": [],
            "picture": "<url>",
            "nickname": "ny",
            "amenities": [],
            "marketing_content": {},
            "beds": "2",
            "baths": "1",
            "city_name": "New York",
            "lat": "42.166723",
            "lng": "34.445245",
            "accommodates": "1",
            "extra_info": {},
            "days_rates": {},
            "is_multi_unit": {},
            "ota_type": {},
            "address": {}
         }
        ],
        "page_info": {
          "count": 1,
          "page": 1,
          "per_page": 50
        }
  end

  before do
    Rails.cache.clear
    allow(External::Client).to receive(:new).and_return(mock_client)
  end

  describe '.search' do
    context 'with successful API response' do
      before do
        allow(mock_client).to receive(:get).with('/search', search_params).and_return(sample_results)
      end

      it 'returns hotel search results' do
        result = described_class.search(search_params)
        expect(result).to eq(sample_results)
      end

      it 'caches the results' do
        described_class.search(search_params)
        cache_key = "v1:search:123:2024-01-15:2024-01-20:a2:c1"
        expect(Rails.cache.exist?(cache_key)).to be true
      end

      it 'returns cached results on subsequent calls' do
        # First call should hit the API
        described_class.search(search_params)
        expect(mock_client).to have_received(:get).once
        
        # Second call should use cache, so no additional API calls
        result = described_class.search(search_params)
        expect(result).to eq(sample_results)
        expect(mock_client).to have_received(:get).once # Still only called once
      end
    end

    context 'with API error' do
      before do
        allow(mock_client).to receive(:get).and_raise(External::Client::Error.new('API Error'))
      end

      it 'raises Hotels::Error' do
        expect { described_class.search(search_params) }.to raise_error(External::Hotels::Error)
      end
    end

    describe 'build_cache_key' do
      it 'generates consistent cache keys' do
        key1 = described_class.send(:build_cache_key, search_params)
        key2 = described_class.send(:build_cache_key, search_params)
        expect(key1).to eq(key2)
        expect(key1).to eq('v1:search:123:2024-01-15:2024-01-20:a2:c1')
      end
    end
  end
end
