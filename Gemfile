source "https://rubygems.org"
ruby "2.6.6"

# Bundle edge Rails instead: gem "rails", github: "rails/rails"
gem "activesupport", ">= 5.2.4.3"
gem "bootsnap"
gem "rack", "2.1.4"
gem "rails", "5.2.4.3"
# Use sqlite3 as the database for Active Record
gem "pg", "~> 0.18"

# Use SCSS for stylesheets
gem "bootstrap_form", "~> 2.7"
gem "bootstrap-sass", "~> 3.4.1"
gem "sass-rails"

# Use Uglifier as compressor for JavaScript assets
gem "uglifier", ">= 1.3.0"
# Use CoffeeScript for .coffee assets and views
gem "coffee-rails"
# See https://github.com/rails/execjs#readme for more supported runtimes
# gem "therubyracer", platforms: :ruby

gem "devise"
gem "simple_token_authentication", "~> 1.0"

# Use jquery as the JavaScript library
gem "jquery-rails"
# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem "turbolinks", "~> 5"
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem "jbuilder", "~> 2.5"

# bundle exec rake doc:rails generates the API under doc/api.
# gem "sdoc", "~> 0.4.0", group: :doc

gem "acts_as_paranoid", "~> 0.6.0"
gem "after_commit_everywhere", "~> 0.1", ">= 0.1.5"
gem "ahoy_email"
gem "aws-sdk-s3", require: false
gem "daemons"
gem "draper"
gem "fast_excel"
gem "figaro"
gem "google-api-client"
gem "js-routes"
gem "phony_rails"
gem "pundit"
gem "ransack"
gem "shopify_api"
gem "sidekiq"
gem "simple_form"
gem "streak-ruby", git: "https://github.com/mostlydev/streak-ruby.git"
gem "zeroclipboard-rails"

# Use ActiveModel has_secure_password
# gem "bcrypt", "~> 3.1.7"

# Use Capistrano for deployment
# gem "capistrano-rails", group: :development

gem "puma"

gem "aasm"
gem "auto_strip_attributes", "~> 2.5"
gem "config"
gem "state_machines"
gem "state_machines-activerecord"

gem "carrierwave"
gem "fog-aws"
gem "mini_magick"
gem "newrelic_rpm"
gem "will_paginate", "~> 3.1.0"

group :development, :test do
  # Call "byebug" anywhere in the code to stop execution and get a debugger console
  gem "byebug"
  gem "dotenv-rails"
  gem "rb-readline"

  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem "spring"
end

group :test do
  gem "minitest-rails-capybara"
  gem "simplecov", require: false
end

group :development do
  gem "letter_opener"
  gem "listen"
  gem "overcommit", require: false
  gem "reek", require: false
  gem "rubocop", require: false
  gem "web-console"
end
