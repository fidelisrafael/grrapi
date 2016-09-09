module Workers
  module V1
    class UpdateLoginStatusHistoricWorker

      include Sidekiq::Worker

      sidekiq_options :retry => 5, queue: :users

      sidekiq_retry_in { |count| count * 60 }

      def perform(user_id, auth_provider)
        user = User.find_by(id: user_id)

        if user
          user.update_login_count_from_provider!(auth_provider)
        end
      end
    end
  end
end
