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
    empty_directory(File.join('app', 'services', app_name, 'v1'))
    empty_directory(File.join('app', 'services', app_name, 'v1'))
    empty_directory(File.join('app', 'workers', app_name, 'v1'))
  end

  def copy_models!
    copy_directory 'migrations', File.join('db', 'migrate')
    copy_directory 'models', File.join('app', 'models')
    copy_directory 'spec', 'spec'
  end

  def append_content_to_files!
    # This file is used by Rack-based servers to start the application.
    append_to_file "config.ru" do
    <<-CODE
    \n
    require 'rack/cors'

    use Rack::Cors do
      # allow all origins in development
      allow do
        origins '*'
        resource '*',
            :headers => :any,
            :methods => [:get, :post, :delete, :put, :options]
      end
    end
    CODE
    end

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
    # load Grape API files
    config.paths.add File.join('app', 'grape'), glob: File.join('**', '*.rb')

    config.autoload_paths << File.join(Rails.root, 'lib')
    config.autoload_paths += Dir.glob(File.join(Rails.root, 'app', 'grape', '{**,*}'))

    config.web_console.development_only = true
      CODE
    end
  end

  def copy_files!
    copy_directory 'api', File.join('app', 'grape', 'api')

    copy_directory 'config', 'config'
    copy_directory 'initializers', File.join('config', 'initializers')

    copy_directory 'deploy', File.join('config', 'deploy')

    copy_directory 'lib', 'lib'

    copy_directory 'rake_tasks', File.join('lib', 'tasks')

    copy_file_to 'Capfile'
    copy_file_to 'Procfile'
    copy_file_to 'contributors.txt'
    copy_file_to '.rspec'
  end

  def remove_files!
    remove_dir 'app/controllers'
    remove_dir 'app/helpers'
    remove_dir 'app/assets'
    remove_dir 'app/views'
  end

  def setup_routes!
    route "mount API::Base => '/'"
  end

  def setup_gems!
    gem_group :development do
      gem 'brakeman', require: false
      gem 'letter_opener'
      gem 'rubocop', require: false
      gem 'pry'
    end

    gem_group :staging, :test do
      gem 'factory_girl_rails', '~> 4.0'
      gem 'rspec-rails', '~> 3.0'
      gem 'shoulda-matchers', '~> 3.1'
      gem 'nyan-cat-formatter'
    end

    # deploy specific
    gem_group :development do
      gem 'capistrano',         require: false
      gem 'capistrano-rvm',     require: false
      gem 'capistrano-rails',   require: false
      gem 'capistrano-bundler', require: false
      gem 'capistrano3-puma',   require: false
      gem 'capistrano-sidekiq', require: false

      # mão na roda!
      gem 'capistrano-rails-tail-log', require: false
      gem 'capistrano-rails-console', require: false

      # ensure folders creation and ownership
      gem 'capistrano-safe-deploy-to', '~> 1.1.1', require: false

      # good
      gem 'capistrano-ssh-doctor', '~> 1.0'

      # pretty print for capistrano tasks
      gem 'airbrussh', :require => false

      # srever selection on deploy (in case theres more than 1 server)
      gem 'capistrano-hostmenu', require: false

      # useful rails tasks
      gem 'capistrano-rails-collection'
    end

    # TODO: Organizar por ordem alfabetica e grupos
    gem 'database_cleaner'
    gem 'carrierwave', require: ['carrierwave', 'carrierwave/orm/activerecord']
    gem 'fog'
    gem 'piet'
    gem 'sinatra', require: false
    gem 'sidekiq'
    gem 'faker'
    gem 'simple_services', git: 'git@bitbucket.org:fidelisrafael/simple_services.git', branch: 'master'
    gem 'bcrypt', '~> 3.1.7'
    gem 'figaro'
    gem 'rollbar', '~> 1.4.4'
    gem 'puma'
    gem 'grape', '~> 0.12'
    gem 'rack-contrib'
    gem 'rack-cors', :require => 'rack/cors'
    gem 'grape-swagger'
    gem 'colorize'
    gem 'active_model_serializers', '0.9.3'
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


