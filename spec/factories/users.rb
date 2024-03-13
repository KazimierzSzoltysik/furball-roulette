# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "example-#{n}-#{rand(1...10_000)}@discidius.com" }
    password { 'password' }
    password_confirmation { 'password' }
    petfinder_token { 'petfinder-token' }
  end
end
