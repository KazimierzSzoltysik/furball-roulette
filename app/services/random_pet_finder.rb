# frozen_string_literal: true

class RandomPetFinder
  def self.perform(*) = new(*).perform

  def initialize(user) = @user = user

  def perform = find_page(random_page_number)['animals'].sample

  private

  attr_reader :user

  def random_page_number = rand(number_of_pages).succ

  def number_of_pages = find_page(1).dig('pagination', 'total_pages')

  def find_page(page) = JSON.parse(api_client.get_animals(page:).body)

  def api_client = @api_client ||= Petfinder::ApiClient.new(user)
end
