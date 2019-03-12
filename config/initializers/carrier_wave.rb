# frozen_string_literal: true

CarrierWave.configure do |config|
  if Rails.env.test? || Rails.env.cucumber?
    config.storage = :file
    config.enable_processing = false
    config.root = Rails.root.join('tmp')
    config.cache_dir = "#{Rails.root}/tmp/uploads"
  else
#    config.storage = :fog
    config.fog_provider = 'fog/aws'
    config.fog_public = false
    config.fog_directory = ENV['S3_BUCKET_NAME']
    config.fog_credentials = {
        provider: 'AWS',
        aws_access_key_id: ENV['S3_KEY'],
        aws_secret_access_key: ENV['S3_SECRET'],
        region: ENV['S3_REGION']
    }
    config.asset_host = "#{ENV["S3_ASSET_HOST"]}/#{ENV["S3_BUCKET_NAME"]}"
    config.root = Rails.root.join('tmp')
    config.cache_dir = "#{Rails.root}/tmp/uploads"
  end
end
