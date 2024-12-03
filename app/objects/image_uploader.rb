# frozen_string_literal: true

# This is a specialized shrine uploader for images
class ImageUploader < Shrine
  # Generates a unique location for the uploaded file, preserving the
  # file extension.
  # @param io [#read] An "IO-like" object, for more details see https://shrinerb.com/docs/getting-started#io-abstraction
  # @return [String]
  def generate_location(io, **)
    profile_and_type_location(io, **)
  end

  # Generates a location based on profile-id and type of image
  # For instance, will generate things like:
  # /profile_picture/11111111-1111-7111-b111-111111111111/cb4fead81fcc2eeafefc439577de40be.jpeg
  # @param io (see #generate_location)
  # @param version [String,#to_s]
  # @param derivative [String,#to_s]
  # @param metadata [Hash]
  # @return [String]
  def profile_and_type_location(io, version: nil, derivative: nil, metadata: {}, **)
    basename = basic_location(io, metadata: metadata)
    basename = [*(version || derivative), basename].join("-")

    type = metadata[:type]
    profile_id = metadata[:profile_id]
    [type, profile_id, basename].compact.join("/")
  end

  # TODO: get host from config
  plugin :download_endpoint, prefix: "images", host: "localhost:3000"
end
