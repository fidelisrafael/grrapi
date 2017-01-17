module GrappiTemplate
  module Auth

    module_function
    def run_auth_template!
      extend Minimal

      # Copy all minimal template files
      run_minimal_template!

      say "Copying required files for auth template"
      copy_auth_files

      say "Injecting configurations on specific files"
      setup_auth_configurations

      say "Configurating gems"
      setup_auth_gems

      say "Configurating routes"
      setup_auth_routes

      say "Finished applying auth template"
    end

    ### ==== Copy files from this template to new generated Rails project ====

    def copy_auth_files
      copy_auth_concerns
      copy_auth_configs
      copy_auth_factories
      copy_auth_initializers
      copy_auth_helpers
      copy_auth_http_api_routes
      copy_auth_mailers
      copy_auth_migrations
      copy_auth_models
      copy_auth_serializers
      copy_auth_services
      copy_auth_specs
      copy_auth_workers
    end

    def copy_auth_concerns
      copy_auth_global_concerns
      copy_auth_user_concerns
    end

    def copy_auth_global_concerns
      copy_file_to File.join('models', 'concerns', 'user_named.rb'), File.join('app', 'model', 'concerns', 'user_named.rb')
    end

    def copy_auth_user_concerns
      [
        File.join('models', 'concerns', 'user_concerns', 'basic.rb'),
        File.join('models', 'concerns', 'user_concerns', 'auth.rb')
      ].each do |file|
        copy_file file, File.join('app', 'model', 'concerns', 'user_concerns', File.basename(file))
      end
    end

    def copy_auth_configs
      copy_file_to File.join('config', 'sidekiq.yml')
    end

    def copy_auth_factories
      [
        File.join('factories', 'authorizations.rb'),
        File.join('factories', 'origins.rb'),
        File.join('factories', 'users.rb')
      ].each do |file|
        copy_file_to File.join('spec', file)
      end
    end

    def copy_auth_initializers
      copy_file_to File.join('initializers', 'sidekiq.rb'), File.join('config', 'initializers', 'sidekiq.rb')
    end

    def copy_auth_helpers
      [
        File.join('api', 'helpers', 'auth_helpers.rb'),
        File.join('api', 'v1', 'helpers','auth_helpers.rb'),
        File.join('api', 'v1', 'helpers','user_auth_helpers.rb'),
      ].each do |file|
        copy_file_to file, File.join('app', 'grape', file)
      end
    end


    def copy_auth_http_api_routes
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

    def copy_auth_mailers
      copy_file_to File.join('mailers', 'users_mailer.rb'), File.join('app', 'mailers', 'users_mailer.rb')
      copy_directory File.join('views', 'users_mailer'), File.join('app', 'views', 'users_mailer')
    end

    def copy_auth_migrations
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
        copy_file_to File.join('migrations', File.basename(file)), File.join('db', 'migrate', File.basename(file))
      end
    end

    def copy_auth_models
      [
        File.join('models', 'authorization.rb'),
        File.join('models', 'user.rb'),
        File.join('models', 'origin.rb')
      ].each do |file|
        copy_file_to file , File.join('app', 'model', File.basename(file))
      end
    end

    def copy_auth_serializers
      copy_directory File.join('serializers', 'v1', 'auth'), File.join('lib', 'serializers', 'v1', 'auth')
      copy_directory File.join('serializers', 'v1', 'user'), File.join('lib', 'serializers', 'v1', 'user')
    end

    def copy_auth_services
      [
        File.join('services', 'v1', 'auth'),
        File.join('services', 'v1', 'users'),
        File.join('services', 'v1', 'concerns', 'users')
      ].each do |dir|
        copy_directory dir, File.join('lib', dir)
      end

      remove_services
    end

    def remove_services
      remove_file File.join('services', 'v1', 'users', 'notification_create_service.rb')
      remove_file File.join('services', 'v1', 'users', 'preferences_update_service.rb')
      remove_file File.join('services', 'v1', 'users', 'profile_image_update_service.rb')
    end

    def copy_auth_specs
      [
        File.join('models', 'authorization_spec.rb'),
        File.join('models', 'origin_spec.rb'),
        File.join('models', 'user_spec.rb')
      ].each do |file|
        copy_file_to File.join('spec', file)
      end
    end

    def copy_auth_workers
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

    def setup_auth_configurations
      configure_auth_user_model
    end

    def configure_auth_user_model
      inject_into_file File.join('app', 'model', 'user.rb') , after: "#==markup==\n" do
        <<-CODE

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

    def setup_auth_gems
      setup_auth_core_gems
      setup_auth_deploy_gems
    end

    def setup_auth_core_gems
      # just to keep alphabetical organization in Gemfile
      inject_into_file 'Gemfile', after: "gem 'database_cleaner'\n" do
        <<-CODE
gem 'faker'
        CODE
      end

      inject_into_file 'Gemfile', before: "gem 'rollbar'\n" do
        <<-CODE
gem 'redis-namespace'
gem 'sidekiq'
gem 'sinatra', require: false
      CODE
      end
    end

    def setup_auth_deploy_gems
      inject_into_file 'Gemfile', after: "gem 'capistrano-safe-deploy-to', '~> 1.1.1', require: false\n" do
        <<-CODE
    gem 'capistrano-sidekiq', require: false
        CODE
      end
    end

    ### ==== Routes setup ====

    def setup_auth_routes
      setup_auth_sidekiq_routes
      mount_auth_grape_endpoints
    end

    def setup_auth_sidekiq_routes
      prepend_to_file File.join("config","routes.rb") do
        <<-CODE
  require 'sidekiq/web'
        CODE
      end

      inject_into_file File.join("config","routes.rb"), after: "mount API::Base => '/'\n" do
        <<-CODE

  # Configure sidekiq basic auth
  Sidekiq::Web.use Rack::Auth::Basic do |username, password|
    username == Application::Config.sidekiq_username && password == Application::Config.sidekiq_password
  end
  # Mount sidekiq Web UI at /sidekiq
  mount Sidekiq::Web, at: '/sidekiq'

        CODE
      end
    end

    def mount_auth_grape_endpoints
      base_file = File.join('app','grape','api','base.rb')
      v1_base_file = File.join('app','grape','api','v1','base.rb')

      inject_into_file base_file, before: "mount V1::Routes::Heartbeat\n" do
        <<-CODE
    helpers API::Helpers::AuthHelpers
        CODE
      end

      inject_into_file v1_base_file, before: "mount V1::Routes::Heartbeat\n" do
        <<-CODE
    helpers API::V1::Helpers::AuthHelpers
        CODE
      end

      inject_into_file v1_base_file, after: "mount V1::Routes::Heartbeat\n" do
        <<-CODE

      mount V1::Routes::Users
      mount V1::Routes::UsersAuth
      mount V1::Routes::UsersAuthSocial
      mount V1::Routes::UsersMe
      mount V1::Routes::UsersMeCacheable

        CODE
      end
    end
  end
end