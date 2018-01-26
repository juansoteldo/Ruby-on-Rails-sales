# frozen_string_literal: true

namespace :db do
  desc "Terminate Postgres users to enable db:drop"
  task pg_terminate: :environment do
    sh "echo 'SELECT pg_terminate_backend(pg_stat_activity.pid) FROM pg_stat_activity WHERE datname = current_database() AND pg_stat_activity.pid <> pg_backend_pid();' | rails db"
  end
end
