# encoding: UTF-8

require 'csv'
require 'json'

module Services
  module V1
    class System::CreateDefaultDataService < BaseActionService

      action_name :create_default_data

      def initialize(options = {})
        super(options)
        @verbose = options.fetch(:verbose, true)
        @actions = [options.delete(:actions) || :all_actions].flatten
      end

      private
      def user_can_execute_action?
        true
      end

      def record_error_key
        :seeds
      end

      def execute_service_action
        with_faker_locale do
          @actions.each do |action|
            self.send(action)
          end
        end
      end

      def with_faker_locale(locale = 'pt-BR', &block)
        last_locale = Faker::Config.locale
        Faker::Config.locale = locale

        yield block if block_given?

        Faker::Config.locale = last_locale

        block
      end

      def all_actions
        find_or_create_states
        find_or_create_cities
        find_or_create_users
      end

      def sample_system_user(last_user = nil)
        unless @system_users
          user_emails = []
          seed_user_images.each_with_index do |user_image, index|
            user_emails << Application::Config.system_user_email % index.next
          end

          @system_users = User.where(email: user_emails)
        end

        begin
          sample_user = @system_users.sample
        end while (last_user.present? ? sample_user == last_user : false)

        sample_user
      end

      def find_or_create_states
        puts "\nAdicionando estados\n"
        states = CSV.parse(File.open(Rails.root.join('docs', 'seeds', 'states.csv'), 'r'))

        states.each_with_index do |state_data, index|
          State.where(name: state_data.first.squish, acronym: state_data.last.squish).first_or_create
          print "\r>> %s/%s" % [index.next, states.size]
        end
      end

      def find_or_create_cities
        cities          = CSV.parse(File.open(Rails.root.join('docs', 'seeds', 'cities.csv'), 'r'))
        cities_by_state = {}

        cities.each do |city_data|
          state = city_data[2].squish.upcase
          cities_by_state[state] ||= []
          cities_by_state[state] << city_data.first.squish
        end

        cities_by_state.each do |state_acronym, cities|
          state = State.where(acronym: state_acronym).first

          if state
            puts "\nAdicionando cidades para o estado: #{state.name}\n"
            cities.each_with_index do |city, index|
              state.cities.where(name: city).first_or_create
              print "\r>> %s/%s" % [index.next, cities.size]
            end
          else
            puts "Estado não encontrado: %s" % state_acronym
          end
        end
      end
      private

      def find_or_create_users
        find_or_create_admin_users
        find_or_create_staff_users
      end

      def find_or_create_staff_users
        create_user("staff_user@myapiproject.com", :staff, first_name: 'Usuario', last_name: 'Staff')
      end

      def find_or_create_admin_users
        admin_email = Application::Config.admin_user_email

        profile_image = File.open(Rails.root.join('docs', 'seeds', 'users', 'admin.jpg'))

        create_user(admin_email, :admin, first_name: 'Staff', last_name: 'User', profile_image: profile_image)
      end

      def seed_user_images
        users_avatar_folder = Rails.root.join('docs', 'seeds', 'users')
        Dir[File.join(users_avatar_folder, '[^admin]*.jpg')].sort
      end

      def find_or_create_collection(seed_filename, class_name, *attributes)
        collection = old_collection = load_seed_file(seed_filename)
        klass = class_name.constantize
        father_associations = nil

        collection.each_with_index do |data, index|
          childrens = data.delete('childrens')
          record = klass.find_or_create_by(data.slice(*attributes.map(&:to_s)))

          if record.persisted?
            if childrens.present? && childrens.any?
              childrens.each_with_index do |children_data, index|
                children = record.children.find_or_create_by(children_data.slice(*attributes))
              end
            end
            print "\r%s/%s" % [index.next, collection.size]
          end
        end

        puts "\nTotal de #{collection.size} #{class_name} adicionadas"
      end
      def create_user(email, profile_type, default_data = {})
        user_password = "#{profile_type.downcase}_password_123"

        params = {
          async: false,
          allow_create_staff_user: true,
          validate_address_city: false,
          api_key: Application::Config.master_api_key,
          send_push_notification: false,
          delivery_email: false,
          create_address: false,
          user: {
            first_name: Faker::Name.first_name,
            last_name: Faker::Name.last_name,
            email: email,
            profile_type: profile_type,
            password: user_password,
            password_confirmation: user_password,
          }.merge(default_data)
        }

        service = Services::V1::Users::CreateService.new(params)
        service.execute

        if service.success?
          service.user.activate_account!

          puts "\nRegistrando usuário com perfil do tipo = '%s' e email '%s'\n" % [profile_type, email]
        else
          puts "\nErro ao cadastrar usuário: #{service.errors}"
        end
      end

      def load_seed_file(filename)
        JSON.load(Rails.root.join('docs', 'seeds', filename))
      end

    end
  end
end
