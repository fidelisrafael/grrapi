module API
  module Helpers
    module CacheDSL

      extend ActiveSupport::Concern

      ALLOWED_PAGINATION_PER_PAGE = (1..10).map { |value| value * 10 }

      included do
        def self.paginated_endpoint(paginate_options = {}, &block)

          paginate_options = {
            per_page: 30,
            max_per_page: 60
          }.merge(paginate_options)

          paginate paginate_options

          params do
            optional :page, type: Integer
            optional :per_page, type: Integer, values: ALLOWED_PAGINATION_PER_PAGE
          end

          yield block
        end

        def self.with_cacheable_endpoints(namespace_name, &block)
          namespace namespace_name, &block

          cache_slug_namespace = Application.cache_slug_namespace

          namespace cache_slug_namespace do
            namespace namespace_name, &block
          end
        end

      end

    end
  end
end
