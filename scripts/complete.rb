require_relative 'helpers'

module GrappiTemplate
  module Complete
    include Helpers

    module_function

    def run
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

    private

    ### ==== Copy files from this template to new generated Rails project ====

    def copy_files
      copy_concerns
      copy_initializers
      copy_services
      copy_uploaders
    end

    def copy_concerns
      [
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
        File.join('initializers', 'uniqueness_validator.rb')
      ].each do |file|
        copy_file_to file, File.join('config', file)
      end
    end

    def copy_http_api
      [
        File.join('api', 'helpers', 'cache_dsl.rb'),
        File.join('api', 'helpers', 'cache_helpers.rb'),
        File.join('api', 'v1', 'helpers','auth_helpers.rb'),
      ].each do |file|
        copy_file_to file, File.join('app', 'grape', file)
      end
    end

    def copy_services
      [
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
          <<-CODE
            Application::Cache.configure(config)
          CODE
        end
      end
    end

    def configure_user_model
      inject_into_file File.join('app', 'models', 'user.rb') , after: "#==markup==\n" do
        <<-CODE
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
        <<-CODE
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
      <<-CODE
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
      # silence is golden
    end

  end
end