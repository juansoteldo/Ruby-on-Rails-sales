# frozen_string_literal: true

CarrierWave.configure do |config|
  if Rails.env.production?
    config.fog_provider = "fog/aws"
    config.fog_public = false
    config.fog_directory = ENV.fetch("S3_BUCKET_NAME", "us-east-1")
    config.fog_credentials = {
      provider: "AWS",
      aws_access_key_id: ENV.fetch("AWS_ACCESS_KEY_ID", Rails.application.credentials[:aws][:access_key_id]),
      aws_secret_access_key: ENV.fetch("AWS_SECRET_ACCESS_KEY", Rails.application.credentials[:aws][:secret_access_key]),
      region: ENV.fetch("S3_REGION", "us-east-1")
    }
    config.asset_host = "https://s3.amazonaws.com/#{ENV.fetch('S3_BUCKET_NAME', 'ctd-api-dev')}"
    config.root = Rails.root.join("tmp")
    config.cache_dir = "#{Rails.root}/tmp/uploads"
  else
    config.storage = :file
    config.enable_processing = false
    config.root = Rails.root.join("tmp")
    config.cache_dir = "#{Rails.root}/tmp/uploads"
  end
end
