require 'rails_helper'

RSpec.describe External::Locations do
  let(:mock_client) { instance_double(External::Client) }
  let(:sample_locations) {[  'New York', 'New Mexico'  ] }

  before do
    Rails.cache.clear
    allow(External::Client).to receive(:new).and_return(mock_client)
  end

  describe '.search' do
    context 'with successful API response' do
      before do
        allow(mock_client).to receive(:get).with('/listings/cities', { q: 'New York' }).and_return(sample_locations)
      end

      it 'returns location data' do
        result = described_class.search('New York')
        expect(result).to eq(sample_locations)
      end

      it 'caches the results' do
        described_class.search('New York')
        expect(Rails.cache.exist?('v1:locations:q:new york')).to be true
      end

      it 'returns cached results on subsequent calls' do
        # First call should hit the API
        described_class.search('New York')
        expect(mock_client).to have_received(:get).once
        
        # Second call should use cache, so no additional API calls
        result = described_class.search('New York')
        expect(result).to eq(sample_locations)
        expect(mock_client).to have_received(:get).once # Still only called once
      end
    end

    context 'with API error' do
      before do
        allow(mock_client).to receive(:get).and_raise(External::Client::Error.new('API Error'))
      end

      it 'raises Locations::Error' do
        expect { described_class.search('New York') }.to raise_error(External::Locations::Error)
      end
    end

    context 'with non-array response' do
      before do
        allow(mock_client).to receive(:get).and_return({ 'error' => 'Not found' })
      end

      it 'returns empty array' do
        result = described_class.search('Invalid')
        expect(result).to eq([])
      end
    end
  end
end
