# frozen_string_literal: true

module Petfinder
  class ApiClient
    class UnauthorizedError < StandardError; end

    CLIENT_ID = Rails.application.credentials.petfinder.api_key
    CLIENT_SECRET = Rails.application.credentials.petfinder.secret
    BASE_URL = "https://api.petfinder.com/v2/"
    MAX_ATTEMPTS = 5

    def initialize(user) = @user = user

    def get_animals(page: 1) = get_request("animals?page=#{page}")

    private

    attr_reader :user

    delegate :petfinder_token, to: :user

    def get_request(target_url, attempt=1)
      raise UnauthorizedError.new("can't get an OAuth token") if attempt >= MAX_ATTEMPTS

      response = get_http_request(target_url)

      if response.code == '401'
        user.update(petfinder_token: fetch_new_access_token)

        get_request(target_url, attempt.succ)
      else
        response
      end
    end

    def fetch_new_access_token
      uri = URI("#{BASE_URL}/oauth2/token")
      headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json; charset=utf-8'
      }
      body = {
        grant_type: 'client_credentials',
        client_id: CLIENT_ID,
        client_secret: CLIENT_SECRET,
      }

      response = Net::HTTP.post(uri, body.to_json, headers)
      raise UnauthorizedError.new("Access token invalid or expired") if response.code == '401'

      JSON.parse(response.body).fetch('access_token', nil)
    end

    def get_http_request(target_url)
      url = URI("#{BASE_URL}#{target_url}")
      http = Net::HTTP.new(url.host, url.port)
      http.use_ssl = true
      http.request(net_http_request(url))
    end

    def net_http_request(url)
      request = Net::HTTP::Get.new(url)
      request['Authorization'] = "Bearer #{petfinder_token}"

      request
    end
  end
end
