require_relative 'helpers'

module GrappiTemplate
  module Full
    include Helpers

    module_function

    def run
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

    private

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
        <<-CODE
          # soft delete
          acts_as_paranoid
        CODE
      end

      inject_into_file File.join('app', 'models', 'user.rb') , after: "#==markup==\n" do
        <<-CODE
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
      <<-CODE
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
        <<-CODE
          mount V1::Routes::Cities
          mount V1::Routes::States
          mount V1::Routes::UsersMeNotifications
        CODE
      end
    end

  end
end