require 'pry'

def source_paths
  [File.expand_path(File.dirname(__FILE__))]
end


module CustomTemplateDSL

  BASE_DIR = 'template_files'

  protected def app_name
    ARGV[1].underscore rescue 'application'
  end

  protected def copy_directory(src, dest)
     directory File.join(BASE_DIR, src), dest
  end


  def copy_file_to(file_src, file_dest = nil)
    copy_file File.join('template_files', file_src), file_dest || File.basename(file_src)
  end

  def create_empty_directories!
    # empty_directory(File.join('app', 'services', app_name, 'v1'))
    # empty_directory(File.join('app', 'workers', app_name, 'v1'))
  end

  def copy_models!
    copy_directory 'migrations', File.join('db', 'migrate')
    copy_directory 'models', File.join('app', 'models')
    copy_directory 'spec', 'spec'
  end

  def append_content_to_files!
    inject_config_ru
    inject_application_rb
    inject_seeds_rb
    inject_environments
  end

  def inject_environments
    Dir.glob('config/environments/*.rb').each do |file|
      prepend_to_file file, "require_relative '../config'\n"
      inject_into_file file, after: "Rails.application.configure do\n" do
<<-CODE
  Application::Cache.configure(config)
  Application::SMTP.configure(config)
CODE
      end
    end
  end

  def inject_config_ru
    # This file is used by Rack-based servers to start the application.
    append_to_file "config.ru" do
    <<-CODE
    \n
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

  def inject_application_rb
    inject_into_class "config/application.rb", 'Application' do
      <<-CODE
    config.middleware.delete "ActionDispatch::Static"
    config.middleware.delete "ActionDispatch::Cookies"
    config.middleware.delete "ActionDispatch::Session::CookieStore"
    config.middleware.delete "ActionDispatch::Flash"
    config.middleware.delete "Rack::MethodOverride"

    config.generators do |g|
      # g.template_engine nil
      g.stylesheets     false
      g.javascripts     false
      g.assets          false
      g.helper          false
    end

    config.time_zone                = 'Brasilia'
    config.i18n.default_locale      = 'pt-BR'.to_sym
    config.i18n.available_locales   = [:en, :'pt-BR']

    # Add lib folder to autoload paths (to auto reload code when changed)
    config.paths.add File.join(Rails.root, 'lib'), glob: File.join('**', '*.rb')
    config.autoload_paths << Rails.root.join('lib')

    # load Grape API files
    config.autoload_paths += Dir.glob(File.join(Rails.root, 'app', 'grape', '{**,*}'))
    config.paths.add File.join(Rails.root, 'app', 'grape'), glob: File.join('**', '*.rb')
      CODE
    end
  end

  def copy_files!
    copy_directories
    copy_files
  end

  def copy_files
    copy_file_to 'Capfile'
    copy_file_to 'Procfile'
    copy_file_to 'contributors.txt'
    copy_file_to '.rspec'
    copy_file_to '.editorconfig'
  end

  def copy_directories
    copy_directory 'api', File.join('app', 'grape', 'api')

    copy_directory 'config', 'config'

    copy_directory 'docs', 'docs'

    copy_directory 'initializers', File.join('config', 'initializers')

    copy_directory 'deploy', File.join('config', 'deploy')

    copy_directory 'lib', 'lib'

    copy_directory 'rake_tasks', File.join('lib', 'tasks')

    copy_directory 'services', File.join('lib', 'services')
    copy_directory 'serializers', File.join('lib', 'serializers')
    copy_directory 'workers', File.join('lib', 'workers')

    copy_directory 'mailers', File.join('app', 'mailers')
    copy_directory 'views', File.join('app', 'views')
    copy_directory 'uploaders', File.join('app', 'uploaders')
  end

  def remove_files!
    remove_dir 'app/controllers'
    remove_dir 'app/helpers'
    remove_dir 'app/assets'
    remove_file 'app/views/layouts/application.html.erb'
    remove_dir 'test' # rails new -T dont create this directory, otherwise delete it
  end

  def setup_routes!
    setup_api_routes
    setup_sidekiq_routes
  end

  def setup_api_routes
    route "mount API::Base => '/'"
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

  def inject_seeds_rb
    append_to_file "db/seeds.rb" do
      <<-CODE
    actions = ENV['ACTIONS'].present? ? ENV['ACTIONS'].split(',').map(&:squish) : nil
    Services::V1::System::CreateDefaultDataService.new(actions: actions).execute
      CODE
    end
  end

  def setup_gems!
    gem 'pg'

    gem_group :development do
      gem 'brakeman', require: false
      gem 'letter_opener'
      gem 'rubocop', require: false
    end

    gem_group :staging, :test do
      gem 'factory_girl_rails', '~> 4.0'
      gem 'rspec-rails', '~> 3.0'
      gem 'shoulda-matchers', '~> 3.1'
      gem 'nyan-cat-formatter'
    end

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
      gem 'capistrano-sidekiq', require: false
      gem 'capistrano-ssh-doctor', '~> 1.0'
      gem 'capistrano3-puma', require: false
    end

    gem 'active_model_serializers', '0.9.3'
    gem 'bcrypt', '~> 3.1.7'
    gem 'carrierwave', require: ["carrierwave", "carrierwave/orm/activerecord"]
    gem 'colorize'
    gem 'dalli'
    gem 'database_cleaner'
    gem 'faker'
    gem 'figaro'
    gem 'fog'
    gem 'grape', '~> 0.12'
    gem 'grape-kaminari'
    gem 'grape-swagger'
    gem 'mini_magick'
    gem 'newrelic_rpm'
    gem 'nifty_services', '~> 0.0.5'
    gem 'paranoia', '~> 2.0.0'
    gem 'parse-ruby-client', git: 'https://github.com/adelevie/parse-ruby-client.git'
    gem 'piet'
    gem 'png_quantizator' # piet it'self already include this gem, but just for sure
    gem 'pry'
    gem 'puma'
    gem 'rack-contrib'
    gem 'rack-cors', require: 'rack/cors'
    gem 'redis-namespace'
    gem 'rollbar', '~> 1.4.4'
    gem 'sidekiq'
    gem 'simplified_cache', git: 'git@bitbucket.org:fidelisrafael/simplified_cache.git', branch: 'master'
    gem 'sinatra', require: false
  end


  def init_template_action!
    copy_files!
    remove_files!
    setup_routes!
    append_content_to_files!
    create_empty_directories!
    copy_models!
    setup_gems!
  end

end

extend CustomTemplateDSL

init_template_action!


