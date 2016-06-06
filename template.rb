require 'pry'

def source_paths
  [File.expand_path(File.dirname(__FILE__))]
end

def app_name
  ARGV[1].underscore rescue 'application'
end

module CustomTemplateDSL
  def copy_file_to(file_src, file_dest = nil)
    copy_file File.join('template_files', file_src), file_dest || File.basename(file_src)
  end

  def copy_file_from(folder, file, dest = nil)
    src = File.join(folder, file)
    dest ||= File.join(File.dirname(src), File.basename(file))

    copy_file_to src, dest
  end

  def copy_file_from_api(file_src, dest = nil)
    copy_file_from 'api', file_src, File.join('app', 'grape', 'api', dest || File.basename(file_src))
  end

  def copy_file_from_config(file_src, dest = nil)
    copy_file_from 'config', file_src, dest
  end

  def copy_file_from_initializers(file_src, dest = nil)
    copy_file_from 'initializers', file_src, File.join('config', 'initializers', dest || File.basename(file_src))
  end

  def copy_file_from_lib(file_src, dest = nil)
    copy_file_from 'lib', file_src, dest
  end

  def copy_file_from_deploy(file_src, dest = nil)
    copy_file_from 'deploy', file_src, File.join('config', 'deploy', dest || File.basename(file_src) )
  end

  def copy_file_from_rake_tasks(file_src, dest = nil)
    copy_file_from 'tasks', file_src, File.join('lib', 'tasks', File.basename(file_src))
  end

  def make_dir(dest)
    FileUtils.mkdir_p(dest)
  end

  def make_empty_dir(dest)
    create_file "#{dest}/.keep"
  end

  def make_empty_dirs!
    make_empty_dir(File.join('app', 'services', app_name, 'v1'))
    make_empty_dir(File.join('app', 'services', app_name, 'v1'))
    make_empty_dir(File.join('app', 'workers', app_name, 'v1'))
  end

  def init_template_action!
    copy_files!
    remove_files!
    setup_gems!
    setup_routes!
    append_to_files!
    make_empty_dirs!
  end

  def remove_files!
    remove_dir 'app/controllers'
    remove_dir 'app/helpers'
    remove_dir 'app/assets'
    remove_dir 'app/views'
  end

  def append_to_files!
    # This file is used by Rack-based servers to start the application.

    append_to_file "config.ru" do
    <<-CODE
    \nrequire 'rack/cors'

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
      CODE
    end

    # TODO: Adicionar autoload paths em config/application.rb
  end

  def copy_files!
    copy_file_from_api 'base.rb'
    copy_file_from_api 'v1_base.rb', File.join('v1', 'base.rb')

    copy_file_from_api 'application_helpers.rb', File.join('helpers', 'application_helpers.rb')
    copy_file_from_api 'application_v1_helpers.rb', File.join('helpers', 'v1', 'application_helpers.rb')

    copy_file_from_config 'application.yml'
    copy_file_from_config 'puma.rb'
    copy_file_from_config '.heroku-deploy'

    copy_file_from_initializers 'app_config.rb'
    copy_file_from_initializers 'ams.rb'
    copy_file_from_initializers 'configs/cache.rb', File.join('configs/cache.rb')
    copy_file_from_initializers 'configs/smtp.rb', File.join('configs/smtp.rb')

    copy_file_to File.join('deploy', 'deploy.rb'), File.join('config', 'deploy.rb')
    copy_file_from_deploy 'staging.rb'
    copy_file_from_deploy 'production.rb'


    copy_file_from_lib 'rake_heroku_deployer.rb'
    copy_file_from_rake_tasks 'app_tasks.rake'

    copy_file_to 'Capfile'
    copy_file_to 'Procfile'
    copy_file_to 'contributors.txt'
  end

  def setup_routes!
    route "mount API::Base => '/'"
  end

  def setup_gems!
    gem_group :development do
      gem 'brakeman', require: false
      gem 'letter_opener'
      gem 'rubocop', require: false
    end

    gem_group :development, :staging, :test do
      gem 'factory_girl_rails', '~> 4.0'
      gem 'shoulda-matchers', require: false
      gem 'nyan-cat-formatter'
      gem 'rspec-rails', '~> 3.0'
      gem 'pry'
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
end

extend CustomTemplateDSL

init_template_action!

