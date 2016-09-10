# encoding: UTF-8

class BaseImageUploader < CarrierWave::Uploader::Base

  include CarrierWave::MiniMagick

  storage Rails.env.development? ? Application::Config.enabled?(:upload_to_s3_in_development) ? :fog : :file : :fog

  def store_dir
    "uploads/#{Rails.env.to_s}/images/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  def extension_white_list
    %w(jpg jpeg png)
  end

  def default_url(*args)
    host = "https://#{Application::Config.aws_bucket_name}.s3.amazonaws.com"
    version = [version_name, "default.png"].compact.join('_')
    image_path = "uploads/#{Rails.env.to_s}/images/#{model.class.to_s.underscore}/fallback/#{version}"

    File.join(host, image_path)
  end

  def unique_filename
    "#{secure_token}.#{file.extension}" if original_filename.present?
  end

  def secure_token
    var = :"@#{mounted_as}_secure_token"
    model.instance_variable_get(var) or model.instance_variable_set(var, SecureRandom.uuid)
  end
end
