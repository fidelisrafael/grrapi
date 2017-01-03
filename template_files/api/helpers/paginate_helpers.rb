module API
  module Helpers
    module PaginateHelpers

      def pagination_cache_replace_data(resource_id = nil)
        [resource_id || params[:id], params[:page], params[:per_page]]
      end

      def response_for_paginated_endpoint(cache_key, cache_resource_id = nil, &block)
        cache_resource_id ||= current_user.try(:id)
        cache_replace_data = pagination_cache_replace_data(cache_resource_id)

        respond_with_cacheable(cache_key, cache_replace_data, &block)
      end

      def pagination_meta
        { pagination: params[:pagination_meta] }
      end

      def paginate(collection)
        paginate_response = super
        set_pagination_meta_params(paginate_response)
        paginate_response
      end

      def paginate_array(array)
        paginate_response = Kaminari.paginate_array(array)
        paginate(paginate_response)
      end

      def set_pagination_meta_params(data)
        pagination_data = {
          total_count: data.total_count,
          total_pages: data.num_pages,
          current_page: data.current_page,
          next_page: data.next_page,
          prev_page: data.prev_page,
          per_page: params[:per_page].to_i
        }

        params[:pagination_meta] = pagination_data
      end

    end
  end
end
