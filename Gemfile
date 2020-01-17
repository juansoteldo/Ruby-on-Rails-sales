source "https://rubygems.org"

# Bundle edge Rails instead: gem "rails", github: "rails/rails"
gem "rails", "5.2.2"
gem "bootsnap"
# Use sqlite3 as the database for Active Record
gem 'pg', '~> 0.18'

# Use SCSS for stylesheets
gem "sass-rails", "~> 5.0"
gem "bootstrap-sass", "~> 3.3.6"
gem "bootstrap_form", "~> 2.7"

# Use Uglifier as compressor for JavaScript assets
gem "uglifier", ">= 1.3.0"
# Use CoffeeScript for .coffee assets and views
gem "coffee-rails", "~> 4.2"
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
#gem "sdoc", "~> 0.4.0", group: :doc

gem "ahoy_email"
gem "aws-sdk-s3", require: false
gem "daemons"
gem "delayed_job"
gem "delayed_job_active_record"
gem "delayed_job_web"
gem "draper"
gem "figaro"
gem "google-api-client"
gem "honeybadger", "~> 3.1"
gem "js-routes"
gem "zeroclipboard-rails"
gem "phony_rails"
gem "pundit"
gem "shopify_api"
gem "simple_form"
gem "streak-ruby", github: "mostlydev/streak-ruby", branch: "master"

# Use ActiveModel has_secure_password
# gem "bcrypt", "~> 3.1.7"

# Use Capistrano for deployment
# gem "capistrano-rails", group: :development

group :production, :staging do
  gem "unicorn"
end

group :development, :test do
  gem "puma"
end

gem "auto_strip_attributes", "~> 2.1"
gem "config"
gem "dotenv-rails"
gem "whenever"
gem "state_machines"
gem "state_machines-activerecord"

gem "carrierwave"
gem "fog-aws"
gem "mini_magick"
gem 'will_paginate', '~> 3.1.0'

group :development, :test do
  # Call "byebug" anywhere in the code to stop execution and get a debugger console
  gem "byebug"

  # Access an IRB console on exception pages or by using <%= console %> in views
  gem "capistrano", "~> 3.1"
  gem "capistrano-bundler"
  gem "capistrano-rails"
  gem "capistrano-rails-console", require: false
  gem "capistrano-rbenv"
  gem 'capistrano-nvm', require: false
  gem "rubocop", require: false
  gem "rubocop-airbnb", require: false
  gem "rb-readline"

  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem "spring"
end

group :development do
  gem "letter_opener"
  gem "listen"
  gem "web-console"
end

