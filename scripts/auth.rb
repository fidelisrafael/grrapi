require_relative 'helpers'

module GrappiTemplate
  module Auth
    include Helpers

    module_function
    def run
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

    private

    ### ==== Copy files from this template to new generated Rails project ====

    def copy_files
      copy_concerns
      copy_configs
      copy_factories
      copy_initializers
      copy_http_api
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

    def copy_http_api
      [
        File.join('api', 'helpers', 'auth_helpers.rb'),
        File.join('api', 'v1', 'helpers','auth_helpers.rb'),
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
    end

    def setup_sidekiq_routes
      prepend_to_file 'config/routes.rb' do
        <<-CODE
    require 'sidekiq/web'
        CODE
      end

      inject_into_file "config/routes.rb", after: "mount API::Base => '/'\n" do
        <<-CODE
    Sidekiq::Web.use Rack::Auth::Basic do |username, password|
      username == Application::Config.sidekiq_username && password == Application::Config.sidekiq_password
    end

    mount Sidekiq::Web, at: '/sidekiq'
        CODE
      end
    end
  end
end