# frozen_string_literal: true

SHRINE_STORAGE_TYPE = if Environment.test?
  # For tests, we want shrine to use memory storage.
  # That will avoid us needing to clean up and whatnot.
  require "shrine/storage/memory"
  Shrine.storages = {
    cache: Shrine::Storage::Memory.new,
    store: Shrine::Storage::Memory.new
  }
  :memory
elsif EnvironmentConfig.shrine_s3_enabled?
  require "shrine/storage/s3"

  s3_options = {
    bucket: EnvironmentConfig.shrine_s3_bucket,
    region: EnvironmentConfig.shrine_s3_region,
    access_key_id: EnvironmentConfig.shrine_aws_access_key_id,
    secret_access_key: EnvironmentConfig.shrine_aws_secret_access_key,
    endpoint: EnvironmentConfig.shrine_s3_endpoint,
    force_path_style: true
  }

  Shrine.plugin :url_options, store: { host: EnvironmentConfig.shrine_s3_cloudfront_host } if EnvironmentConfig.shrine_s3_cloudfront_host

  Shrine.storages = {
    cache: Shrine::Storage::S3.new(prefix: "cache", **s3_options),
    store: Shrine::Storage::S3.new(**s3_options)
  }
  :s3
else
  require "shrine/storage/file_system"

  Shrine.storages = {
    cache: Shrine::Storage::FileSystem.new("public", prefix: "uploads/cache"), # temporary
    store: Shrine::Storage::FileSystem.new("public", prefix: "uploads") # permanent
  }
  :fs
end

Shrine.plugin :rack_file
