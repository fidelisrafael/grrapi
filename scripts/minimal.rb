require_relative 'helpers'

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
  # Configure SMTP server
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