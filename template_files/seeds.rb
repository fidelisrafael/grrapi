actions = ENV['ACTIONS'].present? ? ENV['ACTIONS'].split(',').map(&:squish) : nil
Services::V1::System::CreateDefaultDataService.new(actions: actions).execute
