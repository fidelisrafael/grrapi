module Application

  DEFAULT_CACHE_SLUG_NAMESPACE = :cached

  SimplifiedCache.configure do |config|
    config.environment = Rails.env
    config.config_file = Rails.root.join('config', 'caches.yml')
    config.cache_client = Rails.cache
    config.adapter_name = :simple
    config.adapter_config = {}
  end

  module Cache
    @@client = SimplifiedCache.client

    def self.client
      @@client
    end
  end

  def self.cache_client
    Cache.client
  end

  def self.cache_slug_namespace
    (Application::Config.cache_slug_namespace || DEFAULT_CACHE_SLUG_NAMESPACE).to_sym
  end
end
