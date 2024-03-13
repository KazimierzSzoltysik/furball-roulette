# frozen_string_literal: true

module Api
  module V1
    class PetsController < BaseController
      def random
        render json: find_random_pet
      end

      private

      def find_random_pet = RandomPetFinder.new(current_user).perform
    end
  end
end
