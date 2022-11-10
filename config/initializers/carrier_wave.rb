# frozen_string_literal: true

CarrierWave.configure do |config|
  if Rails.env.production?
    config.fog_provider = 'fog/aws'
    config.fog_public = false
    config.fog_directory = Settings.aws.s3_bucket_name
    config.fog_credentials = {
      provider: 'AWS',
      aws_access_key_id: Settings.aws.access_key_id,
      aws_secret_access_key: Settings.aws.secret_access_key,
      region: Settings.aws.s3_region
    }
    # config.asset_host = "https://s3.amazonaws.com/#{ENV.fetch('S3_BUCKET_NAME', 'ctd-api-dev')}"
    config.asset_host = "#{Settings.aws.s3_asset_host}/#{Settings.aws.s3_bucket_name}"
    config.root = Rails.root.join('tmp')
    config.cache_dir = "#{Rails.root}/tmp/uploads"
  else
    config.storage = :file
    config.enable_processing = false
    config.root = Rails.root.join('tmp')
    config.cache_dir = "#{Rails.root}/tmp/uploads"
  end
end
