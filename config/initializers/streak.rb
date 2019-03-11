# frozen_string_literal: true

Rails.application.configure do
  config.streak_api_cipher_random_key = ENV['STREAK_API_CIPHER_RANDOM_KEY']
  config.streak_api_cipher_random_iv = ENV['STREAK_API_CIPHER_RANDOM_IV']
  config.streak_api_key = ENV['STREAK_API_KEY']
end

