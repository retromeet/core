# frozen_string_literal: true

if Environment.test?
  # For tests, we want shrine to use memory storage.
  # That will avoid us needing to clean up and whatnot.
  require "shrine/storage/memory"
  Shrine.storages = {
    cache: Shrine::Storage::Memory.new,
    store: Shrine::Storage::Memory.new
  }
else
  require "shrine/storage/file_system"

  Shrine.storages = {
    cache: Shrine::Storage::FileSystem.new("public", prefix: "uploads/cache"), # temporary
    store: Shrine::Storage::FileSystem.new("public", prefix: "uploads") # permanent
  }
end

Shrine.plugin :rack_file
