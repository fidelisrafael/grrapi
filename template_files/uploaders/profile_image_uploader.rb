# encoding: UTF-8

class ProfileImageUploader < BaseImageUploader

  include Piet::CarrierWaveExtension

  VERSIONS = {
    thumb: {
      size: [200, 200]
    },
    medium: {
      size: [400, 400],
      process: true
    }
  }

  DEFAULT_JPG_QUALITY = 85
  DEFAULT_PNG_QUALITY = 5

  if Application::Config.enabled?(:compress_images_on_upload)
    process :optimize => [ { quality: DEFAULT_JPG_QUALITY, level: DEFAULT_PNG_QUALITY } ]
  end

  VERSIONS.each do |image_version, options|
    version image_version do
      process resize_to_fit: options[:size]
      if options[:process].present? && Application::Config.enabled?(:compress_images_on_upload)
        process optimize: [ { quality: DEFAULT_JPG_QUALITY, level: DEFAULT_PNG_QUALITY } ]
      end
    end
  end

  def filename
    unique_filename
  end

end
