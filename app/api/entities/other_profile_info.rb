# frozen_string_literal: true

module API
  module Entities
    # Represents another user's profile info for the API
    class OtherProfileInfo < Grape::Entity
      format_with(:age_formatter) do |birth_date|
        next nil if object[:hide_age]

        AgeHelper.age_from_date(birth_date)
      end
      format_with(:distance_in_km) do |distance|
        if distance.nil?
          nil
        else
          distance / 1_000
        end
      end
      format_with(:picture_formatter) do |picture_hash|
        upload = ImageUploader::Attacher.from_data(picture_hash.to_h)
        if SHRINE_STORAGE_TYPE == :s3
          upload.url
        else
          upload.file.download_url
        end
      end
      expose :id, documentation: { type: String, required: false }
      expose :display_name, documentation: { type: String, required: false }
      expose :about_me, documentation: { type: String, required: false }
      expose :genders, documentation: { type: String, is_array: true, required: false }
      expose :orientations, documentation: { type: String, is_array: true, required: false }
      expose :languages, documentation: { type: String, is_array: true, required: false }
      expose :relationship_status, documentation: { type: String, required: false }
      expose :relationship_type, documentation: { type: String, required: false }
      expose :tobacco, documentation: { type: String, required: false }
      expose :alcohol, documentation: { type: String, required: false }
      expose :marijuana, documentation: { type: String, required: false }
      expose :other_recreational_drugs, documentation: { type: String, required: false }
      expose :pets, documentation: { type: String, required: false }
      expose :wants_pets, documentation: { type: String, required: false }
      expose :kids, documentation: { type: String, required: false }
      expose :wants_kids, documentation: { type: String, required: false }
      expose :religion, documentation: { type: String, required: false }
      expose :religion_importance, documentation: { type: String, required: false }
      expose :location_display_name, documentation: { type: Hash, required: false }
      expose :location_distance, format_with: :distance_in_km, documentation: { type: Float }, expose_nil: false
      expose :birth_date, format_with: :age_formatter, as: :age, documentation: { type: Integer, required: false }, if: ->(object, _options) { !object[:hide_age] }
      expose :is_blocked, documentation: { type: "boolean" }, expose_nil: false
      expose :picture, format_with: :picture_formatter, documentation: { type: String }, expose_nil: false
      expose :pronouns, documentation: { type: String, required: false }
    end
  end
end
