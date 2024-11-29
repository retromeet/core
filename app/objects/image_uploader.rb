# frozen_string_literal: true

class ImageUploader < Shrine
  def generate_location(io, **)
    profile_and_type_location(io, **)
  end

  def profile_and_type_location(io, version: nil, derivative: nil, metadata: {}, **args)
    basename = basic_location(io, metadata: metadata)
    basename = [*(version || derivative), basename].join("-")

    type = metadata[:type]
    profile_id = metadata[:profile_id]
    [type, profile_id, basename].compact.join("/")
  end
end
