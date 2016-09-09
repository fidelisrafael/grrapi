require 'figaro'

module Application

  CONFIG = Figaro.env

  module Config

    module_function

    def self.authentication_providers
      JSON.parse(CONFIG.authentication_providers || '[]')
    end

    CONFIG.each_key do |key|
      define_method "#{key}_enabled?" do
        enabled?(key)
      end
    end

    def enabled?(key)
      value = CONFIG.send(key)

      value.eql?('true') || value.eql?(true)
    end

    def disabled?(key)
      !enabled?(key)
    end

    def method_missing(*args)
      CONFIG.send(*args)
    end

    def parse_client
      @parse_client ||= ::Parse.create(parse_client_config)
    end

    def parse_client_config
      {
        application_id: Application::Config.parse_app_id,
        api_key:        Application::Config.parse_api_key,
        master_key:     Application::Config.parse_master_key,
        quiet:          Application::Config.parse_quiet || false
      }
    end

  end

  def self.config
    Config
  end
end
