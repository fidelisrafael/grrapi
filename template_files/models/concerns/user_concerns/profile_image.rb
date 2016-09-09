module UserConcerns
  module ProfileImage

    extend ActiveSupport::Concern

    included do
      mount_uploader :profile_image, ProfileImageUploader

      process_in_background :profile_image if Application::Config.enabled?(:process_image_upload_in_background) ||
                                              Application::Config.enabled?(:process_avatar_upload_in_background)
    end

    def profile_images
      profile_image_versions = self.profile_image.versions
      versions = profile_image_versions.map(&:first)
      images   = profile_image_versions.map(&:last).map(&:url)

      Hash[versions.zip(images)].presence || [self.profile_image_url]
    end

    def has_uploaded_image?
      self.profile_image_url.present? &&
      !self.profile_image_url.match(/(fallback|default)\.(png|jpg|jpeg)\z/)
    end

    def push_notification_image_url
      has_uploaded_image? ? self.profile_image_url : nil
    end
  end
end
