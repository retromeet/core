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
      expose :id, documentation: { type: String }
      expose :display_name, documentation: { type: String }
      expose :about_me, documentation: { type: String }
      expose :genders, documentation: { type: String, is_array: true }
      expose :orientations, documentation: { type: String, is_array: true }
      expose :languages, documentation: { type: String, is_array: true }
      expose :relationship_status, documentation: { type: String }
      expose :relationship_type, documentation: { type: String }
      expose :tobacco, documentation: { type: String }
      expose :alcohol, documentation: { type: String }
      expose :marijuana, documentation: { type: String }
      expose :other_recreational_drugs, documentation: { type: String }
      expose :pets, documentation: { type: String }
      expose :wants_pets, documentation: { type: String }
      expose :kids, documentation: { type: String }
      expose :wants_kids, documentation: { type: String }
      expose :religion, documentation: { type: String }
      expose :religion_importance, documentation: { type: String }
      expose :location_display_name, documentation: { type: Hash }
      expose :location_distance, format_with: :distance_in_km, documentation: { type: Float }, expose_nil: false
      expose :birth_date, format_with: :age_formatter, as: :age, documentation: { type: Integer }, if: ->(object, _options) { !object[:hide_age] }
      expose :is_blocked, documentation: { type: "boolean" }, expose_nil: false
      expose :picture, format_with: :picture_formatter, documentation: { type: String }, expose_nil: false
    end
  end
end
