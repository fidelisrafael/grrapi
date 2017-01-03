module API
  module Helpers
    module CacheHelpers

      FORCE_CACHE_HEADER_NAME = 'X-Cached'
      CACHED_RESPONSE_HEADER = 'X-Cached'
      FORCE_CACHE_PARAM_NAME = :_cache

      def cache_client
        Application.cache_client
      end

      # TODO: Review
      def append_cache_response(response, options = {}, &block)
        block_response = yield block

        response.merge(block_response.as_json)
      end

      def respond_with_cacheable(key, options = {}, &block)
        unless cache_enabled?(key)
          return yield block
        end

        set_cacheable_header
        from_cache(key, options, &block)
      end

      def from_cache(key, options = {}, &block)
        options = options_for_cache(options)

        if save_user_keys_in_cache?(options)
          if Application::Config.enabled?(:save_user_cache_keys)
            options.merge!(save_keys: true, user_id: current_user.try(:id))
          end
        end

        cache_client.fetch(key, options, &block)
      end

      def set_cacheable_header
        header CACHED_RESPONSE_HEADER, 'cached'
      end

      def options_for_cache(options)
        if (options.is_a?(Hash) && options[:replace_data].present? && options.length > 1)
          return options
        end

        return { replace_data: options } if [Array, Hash].member?(options.class)
        return { replace_data: [options] } unless options.is_a?(Array)

        options
      end

      def force_cache_for_key?(key = nil)
        key_data = cache_client.data_for_key(key)

        [true, 'true'].member?(key_data[:force])
      end

      def cache_enabled?(key = nil)
        return true if force_cache_for_key?(key)
        return true if Application::Config.enabled?(:global_cache_enabled)

        return cache_enabled_for_request?
      end

      def cache_enabled_for_request?
        cache_slug_namespace = %r(#{Application.cache_slug_namespace})
        return true if request.fullpath.match(cache_slug_namespace)
        return [params[FORCE_CACHE_PARAM_NAME], headers[FORCE_CACHE_HEADER_NAME]].any?(&:present?)
      end

      def save_user_keys_in_cache?(options)
        options[:save_keys].present?
      end
    end
  end
end
