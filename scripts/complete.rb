require_relative 'helpers'

module GrappiTemplate
  module Complete
    include Helpers

    module_function

    def run_complete_template!
      extend Full

      # Copy all minimal + auth + full template files
      run_full_template!

      say "Copying required files for complete template"
      copy_complete_files

      say "Injecting configurations on specific files"
      setup_complete_configurations

      say "Configurating gems"
      setup_complete_gems

      say "Configurating routes"
      setup_complete_routes

      say "Finished applying complete template"
    end


    ### ==== Copy files from this template to new generated Rails project ====

    def copy_complete_files
      copy_complete_concerns
      copy_complete_initializers
      copy_complete_helpers
      copy_complete_http_api_routes
      copy_complete_services
      copy_complete_uploaders
    end

    def copy_complete_concerns
      [
        File.join('models', 'concerns', 'user_concerns', 'preferences.rb'),
        File.join('models', 'concerns', 'user_concerns', 'profile_image.rb'),
      ].each do |file|
        copy_file file, File.join('app', 'model', 'concerns', 'user_concerns', File.basename(file))
      end
    end

    def copy_complete_initializers
      [
        File.join('initializers', 'app_cache.rb'),
        File.join('initializers', 'carrierwave.rb'),
        File.join('initializers', 'piet.rb'),
      ].each do |file|
        copy_file_to file, File.join('config', file)
      end
    end

    def copy_complete_helpers
      [
        File.join('api', 'helpers', 'cache', 'cache_dsl.rb'),
        File.join('api', 'helpers', 'cache', 'cache_helpers.rb'),
      ].each do |file|
        copy_file_to file, File.join('app', 'grape', 'helpers', File.basename(file))
      end
    end

    def copy_complete_http_api_routes
      [
        File.join('api', 'v1', 'routes', 'users_me_preferences.rb'),
        File.join('api', 'v1', 'routes', 'users_me_update_image.rb')
      ].each do |file|
        copy_file_to file, File.join('app', 'grape', file)
      end
    end

    def copy_complete_services
      [
        File.join('services', 'v1', 'users', 'preferences_update_service.rb'),
        File.join('services', 'v1', 'users', 'profile_image_update_service.rb')
      ].each do |file|
        copy_file_to file, File.join('lib', file)
      end
    end

    ### ==== Configuration starts ====

    def setup_complete_configurations
      configure_complete_environments
      configure_complete_user_model
    end

    def configure_complete_environments
      Dir.glob('config/environments/*.rb').each do |file|
        prepend_to_file file, "require_relative '../config'\n"
        inject_into_file file, after: "Application::SMTP.configure(config)\n" do
          <<-CODE.strip_heredoc
            Application::Cache.configure(config)
          CODE
        end
      end
    end

    def configure_complete_user_model
      inject_into_file File.join('app', 'model', 'user.rb') , after: "#==markup==\n" do
        <<-CODE.strip_heredoc
          # User profile images
          include UserConcerns::ProfileImage
        CODE
      end
    end

    def copy_complete_uploaders
      copy_directory 'uploaders', File.join('app', 'uploaders')
    end


    ### ==== Gems setup ====

    def setup_complete_gems
      setup_complete_core_gems
    end

    def setup_complete_core_gems
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

    def setup_complete_routes
      mount_complete_grape_endpoints
    end

    def mount_complete_grape_endpoints
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