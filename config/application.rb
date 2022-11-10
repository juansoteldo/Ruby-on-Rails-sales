require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)
Dotenv::Railtie.load unless ['production', 'staging'].include?(ENV['RAILS_ENV'])

module CtdSales
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.0

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.
    config.time_zone = "Eastern Time (US & Canada)"
    config.active_job.queue_adapter = :sidekiq
    config.action_dispatch.ip_spoofing_check = false
    config.autoload_paths += ["#{config.root}/lib"]
    config.debugging = ENV["DEBUGGER_HOST"].present?
    config.gem "acts_as_singleton"
  end
end
