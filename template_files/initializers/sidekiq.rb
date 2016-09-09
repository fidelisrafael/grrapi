redis_url = ENV['REDISTOGO_URL'] || Application::Config.redis_url.presence
namespace = Application::Config.redis_sidekiq_namespace

Sidekiq.configure_server do |config|
  config.redis = { url: redis_url, namespace: namespace }
end

Sidekiq.configure_client do |config|
  config.redis = { url: redis_url, namespace: namespace }
end
