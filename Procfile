release: rake db:migrate
worker:  bundle exec sidekiq -q default -q mailers
