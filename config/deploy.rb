set :application, 'ctd-worklist'
set :repo_url, 'ssh://git@bitbucket.org/fluxinc/ctd-worklist.git'

set :rbenv_type, :user #:user # system # or :user, depends on your rbenv setup
set :rbenv_ruby, '2.3.1'
set :rbenv_path, '/home/deploy/.rbenv'

# ask :branch, proc { `git rev-parse --abbrev-ref HEAD`.chomp }

set :branch, :unicorn
set :deploy_to, '/u/apps/ctd-worklist'
# set :scm, :git

# set :format, :pretty
#set :log_level, :debug
# set :pty, true

set :linked_files, %w{.env.production}
set :linked_dirs, %w{bin log published_files tmp/pids tmp/cache tmp/sockets vendor/bundle public/system}

# set :default_env, { path: "/opt/ruby/bin:$PATH" }
set :keep_releases, 20
set :keep_assets, 2

namespace :deploy do
  def remote_file_exists?(full_path)
    'true' ==  capture("if [ -e #{full_path} ]; then echo 'true'; fi").strip
  end
  
  def unicorn_is_running?
    'true' == capture("if [ \"`cat #{fetch(:unicorn_pid)}`\" ]; then echo 'true'; fi").strip
  end
  
  set :rails_env, :production
  #set :unicorn_binary, "#{current_path}/bin/unicorn"
  set :unicorn_binary, "unicorn"
  set :unicorn_config, "#{current_path}/config/unicorn.rb"
  set :unicorn_pid, "#{current_path}/tmp/pids/unicorn.pid"  
  
  desc 'Start unicorn application'
    task :start do
    on roles(:app), except: { no_release: true } do 
      within release_path do
        execute :bundle, "exec #{fetch(:unicorn_binary)} -c #{fetch(:unicorn_config)} -E #{fetch(:rails_env)} -D"
      end
    end
  end

  desc 'Stop unicorn application'
    task :stop do
      on roles(:app), except: { no_release: true } do 
      if remote_file_exists?(fetch(:unicorn_pid)) && unicorn_is_running?
        execute "kill -s KILL `cat #{fetch(:unicorn_pid)}`"
      end
    end
  end

  desc 'Ask unicorn to stop'
    task :graceful_stop do
      on roles(:app), except: { no_release: true } do 
        if remote_file_exists?(fetch(:unicorn_pid)) && unicorn_is_running?
          execute "kill -s QUIT `cat #{fetch(:unicorn_pid)}` || :"
        end
    end
  end

  desc 'Reload unicorn'
    task :reload do
      on roles(:app), except: { no_release: true } do 
        execute "kill -s USR2 `cat #{fetch(:unicorn_pid)}` || :"
    end
  end
  
  desc 'Restart application'
    task :restart do
      on roles(:app), except: { no_release: true }, in: :sequence, wait: 15 do
        if remote_file_exists?(fetch(:unicorn_pid)) && unicorn_is_running?
          execute "kill -s KILL `cat #{fetch(:unicorn_pid)}` || :"
        end
        within release_path do
          execute :bundle, "exec #{fetch(:unicorn_binary)} -c #{fetch(:unicorn_config)} -E #{fetch(:rails_env)} -D"
        end
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

