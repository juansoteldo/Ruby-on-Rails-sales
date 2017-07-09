set :application, 'ctd-worklist'
set :repo_url, 'ssh://git@bitbucket.org/fluxinc/ctd-worklist.git'

set :rbenv_type, :user #:user # system # or :user, depends on your rbenv setup
set :rbenv_ruby, '2.3.4'
set :rbenv_path, '/home/deploy/.rbenv'

# ask :branch, proc { `git rev-parse --abbrev-ref HEAD`.chomp }

set :branch, :master
set :deploy_to, '/u/apps/ctd'
# set :scm, :git

# set :format, :pretty
#set :log_level, :debug
# set :pty, true

set :linked_files, %w{.env.production}
set :linked_dirs, %w{log published_files tmp/pids tmp/cache tmp/sockets vendor/bundle public/system}

# set :default_env, { path: "/opt/ruby/bin:$PATH" }
set :keep_releases, 20
set :keep_assets, 2

set :whenever_identifier, ->{ "#{fetch(:application)}_#{fetch(:stage)}" }

set :delayed_job_workers, 2

namespace :deploy do
  def remote_file_exists?(full_path)
    'true' ==  capture("if [ -e #{full_path} ]; then echo 'true'; fi").strip
  end

  set :rails_env, :production
  #set :unicorn_binary, "#{current_path}/bin/unicorn"
  set :unicorn_binary, "unicorn"
  set :unicorn_config, "#{current_path}/config/unicorn.rb"
  set :unicorn_pid, "#{current_path}/tmp/pids/unicorn.pid"

  desc 'Restart unicorn servers and worker'
  task :restart do
    on roles(:app), in: :sequence, wait: 1 do
      execute :sudo, "/sbin/restart api"
      execute :sudo, "/sbin/restart api-worker"
    end
  end
  desc 'Start unicorn servers and worker'
  task :start do
    on roles(:app), in: :sequence, wait: 1 do
      execute :sudo, "/sbin/start api"
      execute :sudo, "/sbin/start api-worker"
    end
  end
  desc 'Stop unicorn servers and worker'
  task :stop do
    on roles(:app), in: :sequence, wait: 1 do
      execute :sudo, "/sbin/stop api"
      execute :sudo, "/sbin/stop api-worker"

    end
  end

  after :restart, :clear_cache do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
      # Here we can do anything such as:
      # within release_path do
      #   execute :rake, 'cache:clear'
      #end
    end
  end

  after :finishing, 'deploy:cleanup'
  after :finished, 'airbrake:deploy'
end

namespace :rails do
  desc "Open the rails console on each of the remote servers"
  task :console do
    on roles(:app) do |host| #does it for each host, bad.
      rails_env = fetch(:stage)
      within release_path do
        execute :bundle, "exec rails console #{rails_env}"
      end
    end
  end
end
