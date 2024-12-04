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
elsif DryTypes::Params::Bool[ENV.fetch("S3_ENABLED", false)]
  require "shrine/storage/s3"

  s3_options = {
    bucket: ENV.fetch("S3_BUCKET"),
    region: ENV.fetch("S3_REGION", "eu-west-1"),
    access_key_id: ENV.fetch("AWS_ACCESS_KEY_ID"),
    secret_access_key: ENV.fetch("AWS_SECRET_ACCESS_KEY"),
    endpoint: ENV.fetch("S3_ENDPOINT", nil),
    force_path_style: true
  }

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
