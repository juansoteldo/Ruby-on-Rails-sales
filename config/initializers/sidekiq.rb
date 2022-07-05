REDIS_OPTIONS = {
  url: ENV.fetch("REDIS_URL", "redis://localhost:6379/0"),
  ssl_params: {
    verify_mode: OpenSSL::SSL::VERIFY_NONE
  }
}

Sidekiq.configure_server do |config|
  config.redis = REDIS_OPTIONS
  config.logger.level = Rails.env.production? ? Logger::WARN : Logger::DEBUG
end

Sidekiq.configure_client do |config|
  config.redis = REDIS_OPTIONS
end
