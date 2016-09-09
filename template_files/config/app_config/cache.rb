module Application
  module Cache
    def self.configure(config)
      _Config = Application::Config

      cache_servers = (ENV["MEMCACHIER_SERVERS"]  || _Config.cache_servers || "").split(",")
      cache_username = ENV["MEMCACHIER_USERNAME"] || _Config.cache_username
      cache_password = ENV["MEMCACHIER_PASSWORD"] || _Config.cache_password

      cache_namespace = _Config.cache_namespace || "application-cache-#{Rails.env}"
      cache_max_size  = (_Config.cache_value_max_bytes || (1024 * 1024) * 10).to_f # 10 MB

      cache_options = {
        :namespace            => cache_namespace,
        :compress             => true,
        :username             => cache_username,
        :password             => cache_password,
        :failover             => true,
        :socket_timeout       => (_Config.cache_socket_timeout || 1.5).to_f,
        :socket_failure_delay => (_Config.cache_socket_failure_delay || 0.2).to_f,
        :value_max_bytes => cache_max_size
      }

      discover_nodes = (_Config.cache_service == 'elastic_cache' && _Config.enabled?(:cache_auto_discover_nodes))

      if cache_servers.present? && discover_nodes

        unless defined?(Dalli::ElastiCache)
          raise "You must include gem 'dalli-elasticache' in your Gemfile when using 'elastic_cache' as cache_service"
        end

        cache_endpoint = cache_servers.first
        # fetch all "disoverable" memcached nodes
        elasticache = Dalli::ElastiCache.new(cache_endpoint)
        cache_servers = elasticache.servers
      end

      config.cache_store = :dalli_store, cache_servers, cache_options if cache_servers.present?
    end
  end
end
