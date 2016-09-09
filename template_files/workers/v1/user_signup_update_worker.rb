module Workers
  module V1
    class UserSignupUpdateWorker
      include Sidekiq::Worker

      sidekiq_options :retry => 5, queue: :users

      sidekiq_retry_in { |count| count * 60 }

      def perform(user_id, options)
        user = User.find_by(id: user_id)

        service = Services::V1::Users::PostSignupUpdateService.new(user, options.deep_symbolize_keys)
        service.execute
      end
    end
  end
end
