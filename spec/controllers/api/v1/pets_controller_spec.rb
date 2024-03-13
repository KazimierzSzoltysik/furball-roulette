# frozen_string_literal: true

require 'rails_helper'

describe Api::V1::PetsController, type: :controller do
  describe 'GET #random' do
    let(:user) { FactoryBot.create(:user) }
    let(:petfinder_json_response) { File.read('spec/files/petfinder-result.json') }
    it 'redirects non signed in user to the new user session path' do
      get :random
      expect(response.status).to redirect_to(new_user_session_path)
    end

    it 'returns random pet for current user' do
      allow_any_instance_of(Object).to receive(:rand).and_return(4096)

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
        .to_return(status: 200, body: petfinder_json_response, headers: {})

      stub_request(:get, 'https://api.petfinder.com/v2/animals?page=4097')
        .with(
          headers: {
            'Accept' => '*/*',
            'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
            'Authorization' => 'Bearer petfinder-token',
            'Host' => 'api.petfinder.com',
            'User-Agent' => 'Ruby'
          }
        )
        .to_return(status: 200, body: petfinder_json_response, headers: {})

      sign_in user

      get :random
      expect(response.status).to eql(200)
      expect(JSON.parse(response.body).keys).to match_array(
        %w[
          id
          organization_id
          url
          type
          species
          breeds
          colors
          age
          gender
          size
          coat
          attributes
          environment
          tags
          name
          description
          organization_animal_id
          photos
          primary_photo_cropped
          videos
          status
          status_changed_at
          published_at
          distance
          contact
          _links
        ]
      )
    end
  end
end
