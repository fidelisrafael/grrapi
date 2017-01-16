### ATTENTION:
### This file is auto generated by `generate-unique-file.rb`. Please, don't edit this file.
### If you want to edit this code, please refer to files in scripts/ folder

require 'pry'

def source_paths
  [File.expand_path(File.dirname(__FILE__))]
end
module GrappiTemplate

  BASE_DIR = File.expand_path(File.join(File.dirname(__FILE__), 'template_files'))

  module Helpers
    protected def app_name
      Rails.application.class.parent_name.underscore
      # ARGV[1].underscore rescue 'application'
    end

    protected def copy_directory(src, dest = nil)
      new_src = File.join(BASE_DIR, src)
      directory new_src, dest.nil? ? src : dest
    end

    def copy_file_to(file_src, file_dest = nil)
      copy_file File.join(BASE_DIR, file_src), file_dest || file_src
    end
  end
end


module GrappiTemplate
  module Minimal
    include Helpers

    module_function
    def run_template!
      puts "Removing useless Rails files"
      remove_files

      puts "Copying required files for minimal template"
      copy_files

      puts "Injecting configurations on specific files"
      setup_configurations

      puts "Configurating gems"
      setup_gems

      puts "Configurating routes"
      setup_routes

      puts "Finished applying minimal template"
    end

    ### ==== Remove files from generated Rails project and copy template files ====

    # remove all rails crap
    def remove_files
      remove_dir 'app/controllers'
      remove_dir 'app/helpers'
      remove_dir 'app/assets'
      remove_dir 'test' # rails new -T dont create this directory, otherwise delete it
      remove_file 'app/views/layouts/application.html.erb'
    end

    def copy_files
      copy_concerns
      copy_configs
      copy_configs_other
      copy_deploy
      copy_docs
      copy_initializers
      copy_libs
      copy_locales
      copy_helpers
      copy_http_api_routes
      copy_mailers
      copy_rake_tasks
      copy_services
      copy_specs
    end

    def copy_concerns
      copy_file_to File.join('models', 'concerns', 'accessable.rb'), File.join('app', 'model', 'concerns', 'accessable.rb')
    end

    def copy_configs
      copy_directory File.join('config', 'app_config')
      copy_file_to File.join('config', 'application.yml')
      copy_file_to File.join('config', 'config.rb')
      copy_file_to File.join('config', 'puma.rb')
    end

    def copy_configs_other
      copy_file_to 'Procfile'
      copy_file_to 'contributors.txt'
      copy_file_to '.rspec'
      copy_file_to '.editorconfig'
    end

    def copy_deploy
      copy_file_to 'Capfile'
      copy_file_to File.join('config', 'heroku-deploy.yml')
      copy_directory 'deploy', File.join('config', 'deploy')
    end

    def copy_docs
      copy_directory 'docs', 'docs'
    end

    def copy_initializers
      [
        File.join('initializers', 'ams.rb'), # active model serializer
        File.join('initializers', 'app_config.rb'),
        File.join('initializers', 'loaders.rb'),
        File.join('initializers', 'new_relic_grape.rb'),
        File.join('initializers', 'nifty_services_setup.rb'),
        File.join('initializers', 'rollbar.rb'),
        File.join('initializers', 'services_setup.rb')
      ].each do |file|
        copy_file_to file, File.join('config', 'initializers', file)
      end
    end

    def copy_libs
      copy_file_to File.join('lib', 'rake_heroku_deployer.rb')
    end

    def copy_locales
      copy_file_to File.join('config', 'locales', 'service_response.en.yml')
      copy_file_to File.join('config', 'locales', 'service_response.pt-BR.yml')
    end

    def copy_helpers
      [
        File.join('api', 'helpers', 'application_helpers.rb'),
        File.join('api', 'helpers', 'paginate_helpers.rb'),
        File.join('api', 'v1', 'helpers', 'application_helpers.rb')
      ].each do |file|
        copy_file_to file, File.join('app', 'grape', file)
      end
    end

    def copy_http_api_routes
      [
        File.join('api', 'base.rb'),
        File.join('api', 'v1', 'base.rb'),
        File.join('api', 'v1', 'routes', 'heartbeat.rb')
      ].each do |file|
        copy_file_to file, File.join('app', 'grape', file)
      end
    end

    def copy_mailers
      copy_file_to File.join('mailers', 'application_mailer.rb'), File.join('app', 'mailers', 'application_mailer.rb')
      copy_directory File.join('views', 'layouts', 'mailer.html.erb'), File.join('app', 'views', 'layouts', 'mailer.html.erb')
    end

    def copy_rake_tasks
      copy_directory 'rake_tasks', File.join('lib', 'tasks')
    end

    # In minimal setup only system services are necessary
    def copy_services
      copy_directory File.join('services', 'v1', 'system'), File.join('lib', 'services', 'v1', 'system')
    end

    def copy_specs
      copy_spec_config
    end

    def copy_spec_config
      copy_file_to File.join('spec', 'spec_helper.rb')
      copy_file_to File.join('spec', 'rails_helper.rb')
    end

    ### ==== Configuration setup starts ====

    def setup_configurations
      configure_application_rb
      configure_config_ru
      configure_environments
      configure_seeds_rb
    end

    def configure_application_rb
      inject_into_class "config/application.rb", 'Application' do
        <<-CODE
    # we're dropping not necessarily middlewares for API HTTP request processing
    config.middleware.delete "ActionDispatch::Static"
    config.middleware.delete "ActionDispatch::Cookies"
    config.middleware.delete "ActionDispatch::Session::CookieStore"
    config.middleware.delete "ActionDispatch::Flash"
    config.middleware.delete "Rack::MethodOverride"

    # Since it's an API, we dont need to generate any kind of asset or views(only for mailers)
    config.generators do |g|
      # g.template_engine nil
      g.stylesheets     false
      g.javascripts     false
      g.assets          false
      g.helper          false
    end

    # Add lib folder to autoload paths (to auto reload code when changed)
    config.paths.add File.join(Rails.root, 'lib'), glob: File.join('**', '*.rb')
    config.autoload_paths << Rails.root.join('lib')

    # load Grape API files
    config.autoload_paths += Dir.glob(File.join(Rails.root, 'app', 'grape', '{**,*}'))
    config.paths.add File.join(Rails.root, 'app', 'grape'), glob: File.join('**', '*.rb')
        CODE
      end
    end

    def configure_config_ru
      # This file is used by Rack-based servers to start the application.
      append_to_file "config.ru" do
      <<-CODE.strip_heredoc
      require 'rack/cors'

      use Rack::Cors do
        # allow all origins in development
        allow do
          origins Application::Config.access_control_allowed_origins
          resource '*',
              :headers => :any,
              :methods => [:get, :post, :delete, :put, :options]
        end
      end
      CODE
      end
    end

    def configure_environments
      Dir.glob('config/environments/*.rb').each do |file|
        prepend_to_file file, "require_relative '../config'\n"
        inject_into_file file, after: "Rails.application.configure do\n" do
          <<-CODE
  Application::SMTP.configure(config)
          CODE
        end
      end
    end

    def configure_seeds_rb
      append_to_file "db/seeds.rb" do
        <<-CODE.strip_heredoc
      actions = ENV['ACTIONS'].present? ? ENV['ACTIONS'].split(',').map(&:squish) : nil
      Services::V1::System::CreateDefaultDataService.new(actions: actions).execute
        CODE
      end
    end

    ### ==== Gems setup ====

    def setup_gems
      setup_core_gems
      setup_deploy_gems
      setup_development_gems
      setup_staging_gems
    end

    def setup_core_gems
      gem 'pg'
      gem 'sequel'

      gem 'active_model_serializers', '0.9.3'
      gem 'bcrypt', '~> 3.1.7'
      gem 'colorize'
      gem 'database_cleaner'
      gem 'figaro'
      gem 'grape', '~> 0.12'
      gem 'grape-swagger'
      gem 'kaminari'
      gem 'newrelic_rpm'
      gem 'nifty_services', '~> 0.0.5'
      gem 'pry'
      gem 'puma'
      gem 'rack-contrib'
      gem 'rack-cors', require: 'rack/cors'
      gem 'rollbar', '~> 1.4.4'
    end

    def setup_deploy_gems
      # deploy specific
      gem_group :development do
        # pretty print for capistrano tasks
        gem 'airbrussh', :require => false

        gem 'capistrano',         require: false
        gem 'capistrano-bundler', require: false
        gem 'capistrano-hostmenu', require: false
        gem 'capistrano-rails',   require: false
        gem 'capistrano-rails-collection', require: false
        gem 'capistrano-rails-console', require: false

        gem 'capistrano-rvm',     require: false
        gem 'capistrano-safe-deploy-to', '~> 1.1.1', require: false
        gem 'capistrano-ssh-doctor', '~> 1.0'
        gem 'capistrano3-puma', require: false
      end
    end

    def setup_development_gems
      gem_group :development do
        gem 'brakeman', require: false
        gem 'letter_opener'
        gem 'rubocop', require: false
      end
    end

    def setup_staging_gems
      gem_group :staging, :test do
        gem 'factory_girl_rails', '~> 4.0'
        gem 'rspec-rails', '~> 3.0'
        gem 'shoulda-matchers', '~> 3.1'
        gem 'nyan-cat-formatter'
      end
    end

    ### ==== Setup routes ====

    # Send all requests to Grape
    def setup_routes
      route "mount API::Base => '/'"
    end
  end
end


module GrappiTemplate
  module Auth
    include Helpers

    module_function
    def run_template!
      puts "Copying required files for auth template"
      copy_files

      puts "Injecting configurations on specific files"
      setup_configurations

      puts "Configurating gems"
      setup_gems

      puts "Configurating routes"
      setup_routes

      puts "Finished applying auth template"
    end

    ### ==== Copy files from this template to new generated Rails project ====

    def copy_files
      copy_concerns
      copy_configs
      copy_factories
      copy_initializers
      copy_helpers
      copy_http_api_routes
      copy_mailers
      copy_migrations
      copy_models
      copy_serializers
      copy_services
      copy_specs
      copy_workers
    end

    def copy_concerns
      copy_global_concerns
      copy_user_concerns
    end

    def copy_global_concerns
      copy_file_to File.join('models', 'concerns', 'user_named.rb'), File.join('app', 'model', 'concerns', 'user_named.rb')
    end

    def copy_user_concerns
      [
        File.join('models', 'concerns', 'user_concerns', 'basic.rb'),
        File.join('models', 'concerns', 'user_concerns', 'auth.rb')
      ].each do |file|
        copy_file file, File.join('app', 'model', 'concerns', 'user_concerns', File.basename(file))
      end
    end

    def copy_configs
      copy_file_to File.join('config', 'sidekiq.yml')
    end

    def copy_factories
      [
        File.join('factories', 'authorizations.rb'),
        File.join('factories', 'origins.rb'),
        File.join('factories', 'users.rb')
      ].each do |file|
        copy_file_to File.join('spec', file)
      end
    end

    def copy_initializers
      copy_file_to File.join('initializers', 'sidekiq.rb'), File.join('config', 'initializers', 'sidekiq.rb')
    end

    def copy_helpers
      [
        File.join('api', 'helpers', 'auth_helpers.rb'),
        File.join('api', 'v1', 'helpers','auth_helpers.rb'),
        File.join('api', 'v1', 'helpers','user_auth_helpers.rb'),
      ].each do |file|
        copy_file_to file, File.join('app', 'grape', file)
      end
    end


    def copy_http_api_routes
      [
        File.join('api', 'v1', 'routes', 'users.rb'),
        File.join('api', 'v1', 'routes', 'users_auth.rb'),
        File.join('api', 'v1', 'routes', 'users_auth_social.rb'),
        File.join('api', 'v1', 'routes', 'users_me.rb'),
        File.join('api', 'v1', 'routes', 'users_me_cacheable.rb'),
      ].each do |file|
        copy_file_to file, File.join('app', 'grape', file)
      end
    end

    def copy_mailers
      copy_file_to File.join('mailers', 'users_mailer.rb'), File.join('app', 'mailers', 'users_mailer.rb')
      copy_directory File.join('views', 'users_mailer'), File.join('app', 'views', 'users_mailer')
    end

    def copy_migrations
      # Basic migrations for authentication & user handling
      migrations = [
        'create_users',
        'create_authorization',
        'add_auth_columns_to_user',
        'create_origins',
        'change_unique_indexes_in_users'
      ]

      migrations_to_copy = Dir[File.join(BASE_DIR, 'migrations', '*.rb')].select do |file|
        # remove the extension and timestamp to be more easier to verify
        basename = File.basename(file, '.rb').sub(/\A\d+_(\w+)$/) { $1 }
        migrations.member?(basename)
      end.each do |file|
        copy_file_to File.join('migrations', file), File.join('db', 'migrate', file)
      end
    end

    def copy_models
      [
        File.join('models', 'authorization.rb'),
        File.join('models', 'user.rb'),
        File.join('models', 'origin.rb')
      ].each do |file|
        copy_file_to file , File.join('app', 'model', File.basename(file))
      end
    end

    def copy_serializers
      copy_directory File.join('serializers', 'v1', 'auth'), File.join('lib', 'serializers', 'v1', 'auth')
      copy_directory File.join('serializers', 'v1', 'user'), File.join('lib', 'serializers', 'v1', 'user')
    end

    def copy_services
      [
        File.join('services', 'v1', 'auth'),
        File.join('services', 'v1', 'users'),
        File.join('services', 'v1', 'concerns', 'users')
      ].each do |dir|
        copy_directory file, File.join('lib', dir)
      end

      remove_services
    end

    def remove_services
      remove_file File.join('services', 'v1', 'users', 'notification_create_service.rb')
      remove_file File.join('services', 'v1', 'users', 'preferences_update_service.rb')
      remove_file File.join('services', 'v1', 'users', 'profile_image_update_service.rb')
    end

    def copy_specs
      [
        File.join('models', 'authorization_spec.rb'),
        File.join('models', 'origin_spec.rb'),
        File.join('models', 'user_spec.rb')
      ].each do |file|
        copy_file_to File.join('spec', file)
      end
    end

    def copy_workers
      [
        File.join('workers', 'v1', 'mail_delivery_worker.rb'),
        File.join('workers', 'v1', 'origin_create_worker.rb'),
        File.join('workers', 'v1', 'user_signup_update_worker.rb'),
        File.join('workers', 'v1', 'update_login_status_historic_worker.rb')
      ].each do |file|
        copy_file_to file, File.join('lib', file)
      end
    end

    ### ==== Configuration starts ====

    def setup_configurations
      configure_user_model
    end

    def configure_user_model
      inject_into_file File.join('app', 'models', 'user.rb') , after: "#==markup==\n" do
        <<-CODE.strip_heredoc
          # Access Level Control
          include Accessable

          # add callbacks to generate user's username based on `name`, `first_name` and/or `last_name`
          include UserNamed

          # Basic user validations and setup
          include UserConcerns::Basic

          # User auth related setup (authentication, account confirmation, password recovery, account block)
          include UserConcerns::Auth
        CODE
      end
    end


    ### ==== Gem setup ====

    def setup_gems
      setup_core_gems
      setup_deploy_gems
    end

    def setup_core_gems
      # just to keep alphabetical organization in Gemfile
      inject_into_file 'Gemfile', after: "gem 'database_cleaner'\n" do
        "gem 'faker'"
      end

      inject_into_file 'Gemfile', before: "gem 'rollbar'\n" do
        "gem 'redis-namespace'"
      end

      inject_into_file 'Gemfile', after: "gem 'rollbar'\n" do
        "gem 'sidekiq'"
        "gem 'sinatra', require: false"
      end
    end

    def setup_deploy_gems
      inject_into_file 'Gemfile', after: "gem 'capistrano-safe-deploy-to', '~> 1.1.1', require: false\n" do
        "gem 'capistrano-sidekiq', require: false"
      end
    end

    ### ==== Routes setup ====

    def setup_routes
      setup_sidekiq_routes
      mount_grape_endpoints
    end

    def mount_grape_endpoints
      base_file = File.join('app','grape','api','base.rb')
      v1_base_file = File.join('app','grape','api','v1','base.rb')

      inject_into_file base_file, after: "helpers API::Helpers::ApplicationHelpers\n" do
        "helpers API::Helpers::AuthHelpers"
      end

      inject_into_file v1_base_file, before: "version 'v1'\n" do
        "helpers API::Helpers::V1::AuthHelpers"
      end

      inject_into_file v1_base_file, after: "version 'v1'\n" do
        <<-CODE.strip_heredoc
          mount V1::Routes::Users
          mount V1::Routes::UsersAuth
          mount V1::Routes::UsersAuthSocial
          mount V1::Routes::UsersMe
          mount V1::Routes::UsersMeCacheable
        CODE
      end
    end

    def setup_sidekiq_routes
      prepend_to_file File.join("config","routes.rb") do
        <<-CODE.strip_heredoc
    require 'sidekiq/web'
        CODE
      end

      inject_into_file File.join("config","routes.rb"), after: "mount API::Base => '/'\n" do
        <<-CODE.strip_heredoc
    Sidekiq::Web.use Rack::Auth::Basic do |username, password|
      username == Application::Config.sidekiq_username && password == Application::Config.sidekiq_password
    end

    mount Sidekiq::Web, at: '/sidekiq'
        CODE
      end
    end
  end
end


module GrappiTemplate
  module Complete
    include Helpers

    module_function

    def run_template!
      puts "Copying required files for complete template"
      copy_files

      puts "Injecting configurations on specific files"
      setup_configurations

      puts "Configurating gems"
      setup_gems

      puts "Configurating routes"
      setup_routes

      puts "Finished applying complete template"
    end


    ### ==== Copy files from this template to new generated Rails project ====

    def copy_files
      copy_concerns
      copy_initializers
      copy_helpers
      copy_http_api_routes
      copy_services
      copy_uploaders
    end

    def copy_concerns
      [
        File.join('models', 'concerns', 'user_concerns', 'preferences.rb'),
        File.join('models', 'concerns', 'user_concerns', 'profile_image.rb'),
      ].each do |file|
        copy_file file, File.join('app', 'model', 'concerns', 'user_concerns', File.basename(file))
      end
    end

    def copy_initializers
      [
        File.join('initializers', 'app_cache.rb'),
        File.join('initializers', 'carrierwave.rb'),
        File.join('initializers', 'piet.rb'),
      ].each do |file|
        copy_file_to file, File.join('config', file)
      end
    end

    def copy_helpers
      [
        File.join('api', 'helpers', 'cache', 'cache_dsl.rb'),
        File.join('api', 'helpers', 'cache', 'cache_helpers.rb'),
      ].each do |file|
        copy_file_to file, File.join('app', 'grape', 'helpers', File.basename(file))
      end
    end

    def copy_http_api_routes
      [
        File.join('api', 'v1', 'routes', 'users_me_preferences.rb'),
        File.join('api', 'v1', 'routes', 'users_me_update_image.rb')
      ].each do |file|
        copy_file_to file, File.join('app', 'grape', file)
      end
    end

    def copy_services
      [
        File.join('services', 'v1', 'users', 'preferences_update_service.rb'),
        File.join('services', 'v1', 'users', 'profile_image_update_service.rb')
      ].each do |file|
        copy_file_to file, File.join('lib', file)
      end
    end

    ### ==== Configuration starts ====

    def setup_configurations
      configure_environments
      configure_user_model
    end

    def configure_environments
      Dir.glob('config/environments/*.rb').each do |file|
        prepend_to_file file, "require_relative '../config'\n"
        inject_into_file file, after: "Application::SMTP.configure(config)\n" do
          <<-CODE.strip_heredoc
            Application::Cache.configure(config)
          CODE
        end
      end
    end

    def configure_user_model
      inject_into_file File.join('app', 'models', 'user.rb') , after: "#==markup==\n" do
        <<-CODE.strip_heredoc
          # User profile images
          include UserConcerns::ProfileImage
        CODE
      end
    end

    def copy_uploaders
      copy_directory 'uploaders', File.join('app', 'uploaders')
    end


    ### ==== Gems setup ====

    def setup_gems
      setup_core_gems
    end

    def setup_core_gems
      # just to keep alphabetical organization in Gemfile
      inject_into_file 'Gemfile', after: "gem 'bcrypt', '~> 3.1.7'\n" do
        <<-CODE.strip_heredoc
          gem 'carrierwave', require: 'carrierwave'
          gem 'carrierwave-sequel', require: 'carrierwave/sequel'
        CODE
      end

      inject_into_file 'Gemfile', after: "gem 'colorize'\n" do
        "gem 'dalli'"
      end

      inject_into_file 'Gemfile', after: "gem 'figaro'\n" do
        "gem 'fog'"
      end

      inject_into_file 'Gemfile', after: "gem 'grape-swagger'\n" do
        "gem 'mini_magick'"
      end

      inject_into_file 'Gemfile', after: "gem 'nifty_services', '~> 0.0.5'\n" do
      <<-CODE.strip_heredoc
        gem 'piet'
        gem 'png_quantizator' # piet it'self already include this gem, but just for sure
      CODE
      end

      inject_into_file 'Gemfile', after: "gem 'sidekiq'\n" do
        "gem 'simplified_cache', git: 'git@bitbucket.org:fidelisrafael/simplified_cache.git', branch: 'master'"
      end
    end

    ### ==== Routes setup ====

    def setup_routes
      mount_grape_endpoints
    end

    def mount_grape_endpoints
      v1_base_file = File.join('app','grape','api','v1','base.rb')

      inject_into_file v1_base_file, after: "mount V1::Routes::UsersMeCacheable\n" do
        <<-CODE.strip_heredoc
          mount V1::Routes::UsersMePreferences
          mount V1::Routes::UsersMeUpdateImage
        CODE
      end

      inject_into_file v1_base_file, before: "version 'v1'\n" do
        <<-CODE.strip_heredoc
          include API::Helpers::CacheDSL
          helpers API::Helpers::CacheHelpers
        CODE
      end
    end

  end
end


module GrappiTemplate
  module Full
    include Helpers

    module_function

    def run_template!
      puts "Copying required files for minimal template"
      copy_files

      puts "Injecting configurations on specific files"
      setup_configurations

      puts "Configurating gems"
      setup_gems

      puts "Configurating routes"
      setup_routes

      puts "Finished applying minimal template"
    end

    ### ==== Copy files from this template to new generated Rails project ====

    def copy_files
      copy_concerns
      copy_initializers
      copy_helpers
      copy_http_api_routes
      copy_models
      copy_services
      copy_workers
    end

    def copy_concerns
      [
        File.join('models', 'concerns', 'user_concerns', 'address.rb'),
        File.join('models', 'concerns', 'user_concerns', 'notifications.rb'),
      ].each do |file|
        copy_file file, File.join('app', 'model', 'concerns', 'user_concerns', File.basename(file))
      end
    end

    def copy_initializers
      [
        File.join('initializers', 'parse_client.rb'),
        File.join('initializers', 'service_notification_setup.rb'),
        File.join('initializers', 'uniqueness_validator.rb')
      ].each do |file|
        copy_file_to file, File.join('config', 'initializers', file)
      end
    end

    def copy_helpers
      [
        File.join('api', 'v1', 'helpers', 'cities_helpers.rb'),
        File.join('api', 'v1', 'helpers', 'states_helpers.rb'),
        File.join('api', 'v1', 'helpers', 'user_notifications_helpers.rb'),
      ].each do |file|
        copy_file_to file, File.join('app', 'grape', file)
      end
    end

    def copy_http_api_routes
      [
        File.join('api', 'v1', 'routes', 'cities.rb'),
        File.join('api', 'v1', 'routes', 'states.rb'),
        File.join('api', 'v1', 'routes', 'users_me_devices.rb'),
        File.join('api', 'v1', 'routes', 'users_me_notifications.rb'),
      ].each do |file|
        copy_file_to file, File.join('app', 'grape', file)
      end
    end

    def copy_models
      [
        File.join('models', 'city.rb'),
        File.join('models', 'state.rb'),
        File.join('models', 'notification.rb'),
        File.join('models', 'user_device.rb')
      ].each do |file|
        copy_file_to file , File.join('app', 'model', File.basename(file))
      end
    end

    def copy_services
      [
        File.join('services', 'v1', 'users', 'notification_create_service.rb'),
      ].each do |file|
        copy_file_to file, File.join('lib', file)
      end

      copy_directory File.join('services', 'v1', 'addresses'), File.join('lib', 'services', 'v1', 'addresses')
      copy_directory File.join('services', 'v1', 'parse'), File.join('lib', 'services', 'v1', 'parse')
    end

    def copy_workers
      [
        File.join('workers', 'v1', 'notification_create_worker.rb'),
        File.join('workers', 'v1', 'parse_device_create_worker.rb'),
        File.join('workers', 'v1', 'parse_device_delete_worker.rb'),
        File.join('workers', 'v1', 'parse_device_save_worker.rb'),
        File.join('workers', 'v1', 'push_notification_delivery_worker.rb')
      ].each do |file|
        copy_file_to file, File.join('lib', file)
      end
    end

    ### ==== Configuration starts ====

    def setup_configurations
      configure_user_model
    end

    def configure_user_model
      inject_into_file File.join('app', 'models', 'user.rb') , after: "class User < ActiveRecord::Base\n" do
        <<-CODE.strip_heredoc
          # soft delete
          acts_as_paranoid
        CODE
      end

      inject_into_file File.join('app', 'models', 'user.rb') , after: "#==markup==\n" do
        <<-CODE.strip_heredoc
          # Notifications
          include UserConcerns::Notifications
        CODE
      end
    end


    ### ==== Gems setup ====

    def setup_gems
      setup_core_gems
    end

    def setup_core_gems
      inject_into_file 'Gemfile', after: "gem 'nifty_services', '~> 0.0.5'\n" do
      <<-CODE.strip_heredoc
        gem 'paranoia', '~> 2.0.0'
        gem 'parse-ruby-client', git: 'https://github.com/adelevie/parse-ruby-client.git'
      CODE
      end
    end

    ### ==== Routes setup ====

    def setup_routes
      mount_grape_endpoints
    end

    def mount_grape_endpoints
      v1_base_file = File.join('app','grape','api','v1','base.rb')

      inject_into_file v1_base_file, after: "mount V1::Routes::UsersMeCacheable\n" do
        <<-CODE.strip_heredoc
          mount V1::Routes::Cities
          mount V1::Routes::States
          mount V1::Routes::UsersMeNotifications
        CODE
      end
    end

  end
end
def init_template_action!(argv)
  application_types = [
    'minimal',
    'auth',
    'complete',
    'full'
  ]
  
  grappi_switch = "--grrapi-template-mode"

  default_app_type = 'minimal'
  current_app_type = argv.find {|v| v.match(/#{grappi_switch}=(w+)/) }

  application_mode = (current_app_type ? (current_app_type.match(/#{grappi_switch}=(w+)/) && $1)  : default_app_type ).downcase

  raise "Invalid application mode #{application_mode}" unless application_types.member?(application_mode)

  extend GrappiTemplate.const_get(application_mode.capitalize)

  run_template!
end

extend GrappiTemplate

init_template_action!(ARGV)
