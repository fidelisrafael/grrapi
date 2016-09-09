module Workers
  module V1
    class OriginCreateWorker

      include Sidekiq::Worker

      sidekiq_options :retry => 5, queue: :origins

      sidekiq_retry_in { |count| count * 60 }

      def perform(options)
        options = options.deep_symbolize_keys!
        origin_params = options.delete(:origin) || options

        fetch_originable = options.delete(:fetch_originable)

        if fetch_originable.eql?(true)

          originable_type = options.delete(:originable_type) || origin_params.delete(:originable_type)
          originable_id   = options.delete(:originable_id) || origin_params.delete(:originable_id)

          originable = originable_type.to_s.classify.constantize.send(:find_by, id: originable_id)

          return false if originable.origin.present?

          originable.create_origin(origin_params)
        else
          Origin.create!(origin_params)
        end
      end
    end
  end
end
