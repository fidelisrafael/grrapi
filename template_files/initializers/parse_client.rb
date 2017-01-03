module Application
  module Config

    module_function

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
end
