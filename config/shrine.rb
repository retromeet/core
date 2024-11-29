# frozen_string_literal: true

# This defines the configuration for shrine.
# Currently it is only using filesystem, but the idea is to be flexible:
# For tests, it will use Memory. Then, it will check for S3 variables to decide whether to use S3-compatible storage or no

require "shrine/storage/file_system"

Shrine.storages = {
  cache: Shrine::Storage::FileSystem.new("public", prefix: "uploads/cache"), # temporary
  store: Shrine::Storage::FileSystem.new("public", prefix: "uploads") # permanent
}

Shrine.plugin :rack_file
