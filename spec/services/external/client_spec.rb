require 'rails_helper'

RSpec.describe External::Client do
  let(:client) { described_class.new }
  let(:mock_response) { double('response') }

  before do
    allow(mock_response).to receive(:status).and_return(200)
    allow(mock_response).to receive(:body).and_return({ 'data' => 'test' })
  end

  describe '#initialize' do
    it 'sets up Faraday connection with correct headers' do
      expect(client.instance_variable_get(:@connection)).to be_a(Faraday::Connection)
    end
  end

  describe '#get' do
    context 'with successful response' do
      before do
        allow(client.instance_variable_get(:@connection)).to receive(:get).and_return(mock_response)
      end

      it 'returns response body for successful requests' do
        result = client.get('/test')
        expect(result).to eq({ 'data' => 'test' })
      end
    end

    context 'with authentication error' do
      before do
        allow(mock_response).to receive(:status).and_return(401)
        allow(mock_response).to receive(:body).and_return({ 'error' => 'Unauthorized' })
        allow(client.instance_variable_get(:@connection)).to receive(:get).and_return(mock_response)
      end

      it 'raises AuthenticationError' do
        expect { client.get('/test') }.to raise_error(External::Client::AuthenticationError)
      end
    end

    context 'with timeout error' do
      before do
        allow(client.instance_variable_get(:@connection)).to receive(:get)
          .and_raise(Faraday::TimeoutError.new('Timeout'))
      end

      it 'raises TimeoutError' do
        expect { client.get('/test') }.to raise_error(External::Client::TimeoutError)
      end
    end
  end

  describe 'auth_header' do
    it 'generates correct Bearer auth header' do
      auth_header = client.send(:auth_header)
      expect(auth_header).to start_with('Bearer ')
      expect(auth_header.split(' ').second.present?).to eq(true')
    end
  end
end

