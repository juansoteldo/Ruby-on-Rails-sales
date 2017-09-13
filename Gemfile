source "https://rubygems.org"

# Bundle edge Rails instead: gem "rails", github: "rails/rails"
gem "rails", "4.2.6"
# Use sqlite3 as the database for Active Record
gem "pg"

# Use SCSS for stylesheets
gem "sass-rails", "~> 5.0"
gem "bootstrap-sass", "~> 3.3.6"

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
gem "honeybadger", "~> 3.1"
gem "js-routes"
gem "bower-rails", "~> 0.11.0"
gem "zeroclipboard-rails"
gem "cancancan", "~> 1.10"
gem "shopify_api"
gem "streak-ruby", github: "OnFrontiers/streak-ruby"
gem "delayed_job"
gem "delayed_job_active_record"
gem "delayed_job_web"
gem "daemons"
gem "figaro"
gem "ahoy_email"
# Use ActiveModel has_secure_password
# gem "bcrypt", "~> 3.1.7"

# Use Capistrano for deployment
# gem "capistrano-rails", group: :development

group :production do
  gem "newrelic_rpm"
  gem "unicorn"
end

gem "auto_strip_attributes", "~> 2.1"
gem "config"
gem "dotenv-rails"
gem "whenever"
gem "state_machines"
gem "state_machines-activerecord"
gem "ruby-progressbar"
gem "carrierwave"
gem "mini_magick"
gem "fog-aws"

group :development, :test do
  # Call "byebug" anywhere in the code to stop execution and get a debugger console
  gem "byebug"
  gem "quiet_assets"

  gem "ruby-debug-ide"
  gem "debase"

  gem "meta_request"
  # Access an IRB console on exception pages or by using <%= console %> in views
  gem "web-console"
  gem "capistrano", "~> 3.1"
  gem "capistrano-rbenv"
  gem "capistrano-bundler"
  gem "capistrano-rails", "~> 1.1"

  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem "spring"
  gem "letter_opener"
  gem "puma"
end

