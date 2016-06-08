set :use_sudo, false

# config valid only for current version of Capistrano
lock '3.4.0'

set :application, ENV['DEPLOY_APP_NAME'] || :my_application
set :repo_url, ENV['GIT_REPO_URL']
set :scm, :git

set :puma_threads,    [4, 16]
set :puma_workers,    1
set :puma_preload_app, true
set :puma_init_active_record, true

### uncomment this if you're deploying to CentoOS Machine
# set :nginx_config_name, -> { "#{fetch(:application)}_#{fetch(:stage)}.conf" }
# set :nginx_sites_available_path, -> { '/etc/nginx/conf.d/sites-available' }
# set :nginx_sites_enabled_path, -> { '/etc/nginx/conf.d/sites-enabled' }

set :linked_files, %w{config/database.yml config/application.yml}
set :linked_dirs, fetch(:linked_dirs, []).push('log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'vendor/bundle', 'public/system')

set :conditionally_migrate, true

set :sidekiq_config, 'config/sidekiq.yml'
set :pty, false # capistrano-sidekiq (There is a known bug that prevents sidekiq from starting when pty is true on Capistrano 3.)

set :rollbar_env, Proc.new { fetch :stage }
set :rollbar_role, Proc.new { :app }

# NEVER SKIP DATA SYNC CONFIRMATION
set :skip_data_sync_confirm, false

# dont allow pushing local to remote
set :disallow_pushing, true

set :migration_role, :app

set :show_host_menu, true

# set :deploy_to, '/var/www/my_app_name'

# set :linked_dirs, fetch(:linked_dirs, []).push('log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'vendor/bundle', 'public/system', 'public/uploads')
# set :linked_files, fetch(:linked_files, []).push('config/database.yml', 'config/secrets.yml', 'config/application.yml')

# Default branch is :master
# ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp

# Default deploy_to directory is /var/www/my_app_name

# Default value for :scm is :git


# Default value for :format is :pretty
# set :format, :pretty

# Default value for :log_level is :debug
# set :log_level, :debug

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
# set :linked_files, fetch(:linked_files, []).push('config/database.yml', 'config/secrets.yml')

# Default value for linked_dirs is []
# set :linked_dirs, fetch(:linked_dirs, []).push('log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'vendor/bundle', 'public/system')

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
# set :keep_releases, 5

namespace :deploy do
  desc "Make sure local git is in sync with remote."
  task :check_revision do
    on roles(:app) do
      unless `git rev-parse HEAD` == `git rev-parse origin/#{fetch(:branch)}`
        puts "WARNING: HEAD is not the same as origin/#{fetch(:branch)}"
        puts "Run `git push` to sync changes."
        exit
      end
    end
  end

  desc 'Initial Deploy'
  task :initial do
    on roles(:app) do
      before 'deploy:restart', 'puma:start'
      invoke 'deploy'
    end
  end

  desc 'Restart application'
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      invoke 'puma:restart'
    end
  end

  desc 'Upload YAML files.'
  task :upload_yml do
    on roles(:app) do
      invoke 'deploy:upload_database_yml'
      invoke 'deploy:upload_application_yml'
    end
  end

  desc 'Upload YAML and restart server'
  task :upload_yml_restarting do
    on roles(:app) do
      invoke 'deploy:upload_yml'
      invoke 'deploy:restart'
    end
  end

  desc 'Upload database.yml only with config for given environment'
  task :upload_database_yml do
    on roles(:app) do
      execute "mkdir #{shared_path}/config -p"

      database_file = "#{shared_path}/config/database.yml"

      if test "[ -f #{database_file} ]" && ENV['FORCE'].nil?
        info "[File not Uploaded] using #{database_file} connection file"
      else
        enviroment = fetch(:puma_env).to_s

        database_yml_file = File.join(File.dirname(__FILE__), 'deploy', 'templates', enviroment, 'database.yml')
        database_data = YAML.load(File.read(database_yml_file))

        file_data = database_data.keep_if {|k, v| k.to_s == enviroment }

        data = YAML.dump file_data

        upload! StringIO.new(data), database_file
      end
    end
  end

  desc 'Upload application.yml'
  task :upload_application_yml do
    on roles(:app) do
      execute "mkdir #{shared_path}/config -p"

      configuration_file = "#{shared_path}/config/application.yml"

      if test "[ -f #{configuration_file} ]" && ENV['FORCE'].nil?
        info "[File not Uploaded] using #{configuration_file} configuration file"
      else
        upload! StringIO.new(File.read('config/application.yml')), configuration_file
      end
    end
  end

  before :starting,  :check_revision
  before :starting,  :upload_yml
  after  :finishing, :cleanup
  after  :published, :restart
end

namespace :puma do
  desc 'Create Directories for Puma Pids and Socket'
  task :make_dirs do
    on roles(:app) do
      execute "mkdir #{shared_path}/tmp/sockets -p"
      execute "mkdir #{shared_path}/tmp/pids -p"
      execute "mkdir #{shared_path}/logs -p"
      execute "mkdir #{shared_path}/log -p"
    end
  end

  before :start, :make_dirs
end

#### REMOVE ALL ASSET RELATED TASKS with `capistrano-rails` add
Rake::Task["deploy:compile_assets"].clear_actions
Rake::Task["deploy:cleanup_assets"].clear_actions
Rake::Task["deploy:normalize_assets"].clear_actions
Rake::Task["deploy:rollback_assets"].clear_actions
