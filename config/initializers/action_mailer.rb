# frozen_string_literal: true

ActionMailer::Base.default_url_options = { host: CTD::URL_HOST }
Rails.application.config.action_mailer.perform_caching = true