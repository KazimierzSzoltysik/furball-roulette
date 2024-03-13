# frozen_string_literal: true

require 'rails_helper'

describe Petfinder::ApiClient do
  describe '#get_animals' do
    let(:user) { FactoryBot.create(:user) }
    let(:oauth_api_body) do
      '{"grant_type":"client_credentials","client_id":"api_key","client_secret":"secret"}'
    end

    it 'raises error when app token is invalid' do
      stub_request(:get, 'https://api.petfinder.com/v2/animals?page=1')
        .with(
          headers: {
            'Accept' => '*/*',
            'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
            'Authorization' => 'Bearer petfinder-token',
            'Host' => 'api.petfinder.com',
            'User-Agent' => 'Ruby'
          }
        )
        .to_return(status: 401, body: '', headers: {})

      stub_request(:post, 'https://api.petfinder.com/v2/oauth2/token')
        .with(
          body: oauth_api_body,
          headers: {
            'Accept' => 'application/json; charset=utf-8',
            'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
            'Content-Type' => 'application/json',
            'Host' => 'api.petfinder.com',
            'User-Agent' => 'Ruby'
          }
        )
        .to_return(status: 401, body: '', headers: {})

      expect { described_class.new(user).get_animals }
        .to raise_error(Petfinder::ApiClient::UnauthorizedError)
    end

    it 'automatically downloads a fresh user token and retrieves data from an external api' do
      stub_request(:get, 'https://api.petfinder.com/v2/animals?page=1')
        .with(
          headers: {
            'Accept' => '*/*',
            'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
            'Authorization' => 'Bearer petfinder-token',
            'Host' => 'api.petfinder.com',
            'User-Agent' => 'Ruby'
          }
        )
        .to_return(status: 401, body: '', headers: {})

      stub_request(:post, 'https://api.petfinder.com/v2/oauth2/token')
        .with(
          body: oauth_api_body,
          headers: {
            'Accept' => 'application/json; charset=utf-8',
            'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
            'Content-Type' => 'application/json',
            'Host' => 'api.petfinder.com',
            'User-Agent' => 'Ruby'
          }
        )
        .to_return(status: 200, body: { access_token: '1234' }.to_json, headers: {})

      stub_request(:get, 'https://api.petfinder.com/v2/animals?page=1')
        .with(
          headers: {
            'Accept' => '*/*',
            'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
            'Authorization' => 'Bearer 1234',
            'Host' => 'api.petfinder.com',
            'User-Agent' => 'Ruby'
          }
        )
        .to_return(status: 200, body: '--response--', headers: {})

      expect(described_class.new(user).get_animals.code).to eq('200')
      expect(user.petfinder_token).to eql('1234')
    end

    it 'returns data when token is valid' do
      stub_request(:get, 'https://api.petfinder.com/v2/animals?page=1')
        .with(
          headers: {
            'Accept' => '*/*',
            'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
            'Authorization' => 'Bearer petfinder-token',
            'Host' => 'api.petfinder.com',
            'User-Agent' => 'Ruby'
          }
        )
        .to_return(status: 200, body: '--response--', headers: {})

      expect(described_class.new(user).get_animals.code).to eq('200')
    end

    it 'returns data for specified page' do
      stub_request(:get, 'https://api.petfinder.com/v2/animals?page=2')
        .with(
          headers: {
            'Accept' => '*/*',
            'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
            'Authorization' => 'Bearer petfinder-token',
            'Host' => 'api.petfinder.com',
            'User-Agent' => 'Ruby'
          }
        )
        .to_return(status: 200, body: '--response--', headers: {})

      expect(described_class.new(user).get_animals(page: 2).code).to eq('200')
    end
  end
end
