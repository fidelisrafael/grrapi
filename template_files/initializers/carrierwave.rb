require 'carrierwave'

if (aws_access_key_id = Application::Config.aws_access_key_id) && (aws_secret_access_key = Application::Config.aws_secret_access_key)
  CarrierWave.configure do |config|

    config.fog_credentials = {
      :provider               => 'AWS',
      :aws_access_key_id      => aws_access_key_id,
      :aws_secret_access_key  => aws_secret_access_key,
      :region                 => Application::Config.aws_region
    }

    config.fog_use_ssl_for_aws = Application::Config.enabled?(:aws_use_ssl)
    config.fog_directory  = Application::Config.aws_bucket_name
    config.fog_public     = true
    config.fog_attributes = {'Cache-Control'=>"max-age=#{Application::Config.aws_cache_max_age}"}

    config.remove_previously_stored_files_after_update = false
  end
end
