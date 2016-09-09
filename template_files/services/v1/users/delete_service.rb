module Services
  module V1
    module Users
      class DeleteService < BaseDeleteService

        record_type ::User

        private
        def user_can_delete_record?
          @user == @record
        end

        def before_destroy_record
          clear_authorizations
        end

        def destroy_record
          @record.destroy
        end

        def after_success
          clear_originated_notifications
        end

        def clear_authorizations
          @record.authorizations.destroy_all
        end

        def clear_originated_notifications
          delete_all_updating_deleted_at(@user.originated_notifications) # working better than .delete_all
        end
        protected

        def delete_all_updating_deleted_at(collection)
          collection.update_all(deleted_at: Time.zone.now)
        end

      end
    end
  end
end
