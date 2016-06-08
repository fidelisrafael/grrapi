require 'simple_services'

module API
  module Helpers
    module ApplicationHelpers

      VALID_LOCALES = [
        :en,
        :"pt-BR"
      ]

      CURRENT_LOCALE_HTTP_HEADER = Application::Config.current_locale_http_header
      CURRENT_LOCALE_HTTP_PARAM  = Application::Config.current_locale_http_param

      DEFAULT_LOCALE = (ENV['LOCALE'] || Application::Config.default_locale || 'en').to_sym

      ALLOWED_PAGINATION_PER_PAGE = (1..10).map { |value| value * 10 }

      def serializer(serializer)
        serializer_by_key_name(serializer).constantize
      end

      def presenter(presenter)
        presenter_by_key_name(presenter).constantize
      end

      def serializer_by_key_name(serializer_name)
        version = env['rack.routing_args'][:version] rescue 'v1'

        serializer_name = get_serializer_name_for_request(serializer_name)

        "#{app_name}/#{version}/#{serializer_name}_serializer".camelize
      end

      def get_serializer_name_for_request(serializer_name)
        if params[:_s].present?
          serializer_type = params[:_s].to_s.downcase == 'simple' ? 'simple' : ''

          if serializer_type == 'simple'
            serializer_name = [serializer_type, serializer_name.to_s.sub(/\Asimple_/, '')].join('_')
          end
        end

        serializer_name
      end

      def presenter_by_key_name(presenter_name)
        version = env['rack.routing_args'][:version] rescue 'v1'

        "#{app_name}/#{version}/#{presenter_name}_presenter".camelize
      end

      def serialized_object(object, options)
        serializer = serializer(options.delete(:serializer))
        options.merge!(scope: current_user)

        serializer.new(object, options)
      end

      def serialized_array(collection, options = {})
        serializer = serializer(options.delete(:serializer))
        options    = options.merge(each_serializer: serializer, scope: current_user)

        ActiveModel::ArraySerializer.new(collection, options)
      end

      def paginated_serialized_array(collection, options = {})
        collection = paginate_array(collection) if options[:paginate]

        if options[:skip_pagination_meta].blank?
          options.merge!(meta: pagination_meta)
          options[:meta].merge!(options.delete(:meta_extra) || {})
        end

        options = options.merge(options)

        serialized_array(collection, options)
      end

      def in_sandbox_environment?
        %w(development staging).member?(Rails.env.to_s)
      end

      def set_locale
        I18n.locale = current_locale
      end

      def locale_from_request
        params[CURRENT_LOCALE_HTTP_PARAM] || headers[CURRENT_LOCALE_HTTP_HEADER]
      end

      def current_locale
        locale       = locale_from_request || DEFAULT_LOCALE
        valid_locale = VALID_LOCALES.member?(locale.to_sym)

        valid_locale ? locale : I18n.default_locale
      end

      def current_ip
        env['HTTP_X_FORWARDED_FOR'] || env['REMOTE_ADDR']
      end

      def origin_object
        @origin ||= {
          provider: authentication_provider,
          ip: current_ip,
          user_agent: env['HTTP_USER_AGENT'],
          locale: current_locale
        }
      end

      def set_origin
        params.merge!(origin: origin_object)
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

      def initialize_service(service_name, *options)
        version = env['rack.routing_args'][:version] rescue 'v1'
        service_class = "::#{app_services_namespace.to_s.camelize}::#{version.to_s.camelize}::#{service_name.to_s.camelize}".constantize

        service_class.send(:new, *options)
      end

      def execute_service(service_name, *options)
        service = initialize_service(service_name, *options)
        service.execute

        service
      end

      private
      def app_name
        Rails.application.class.parent_name
      end

      def app_services_namespace
        # app_name.camelize
        'Services'
      end

    end
  end
end
