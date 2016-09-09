module Workers
  module V1
    class MailDeliveryWorker

      include Sidekiq::Worker

      sidekiq_options :retry => 5, queue: :mailers

      sidekiq_retry_in { |count| count * 60 }

      def perform(options = {})
        options = options.deep_symbolize_keys

        arguments = args_for(options[:mailer], options[:mailer_method], options[:args])

        unless arguments.present?
          user_id = options[:user_id] || options[:args].is_a?(Hash) && options[:args].delete(:user_id)
          user = User.find_by(id: user_id)

          arguments = user if (user && (options[:args].nil? || options[:args].empty?))
        end

        send_mail_for(options[:mailer], options[:mailer_method], *arguments)
      end

      def send_mail_for(mailer, mail_method, *args)
        mailer.to_s.constantize.send(mail_method, *args).deliver
      end

      def args_for(mailer, mail_method, options)
        method_name = "#{mailer.to_s.underscore}_#{mail_method.to_s.underscore}_arguments"

        return nil unless self.respond_to?(method_name, true) # include private methods

        send(method_name, options)
      end

      def users_mailer_welcome_admin_arguments(options)
        [AdminUser.find_by(id: options[:admin_id] || options[:user_id])]
      end
    end
  end
end
