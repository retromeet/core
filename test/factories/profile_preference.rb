# frozen_string_literal: true

class ProfilePreference < Sequel::Model
  many_to_one :profile
end
FactoryBot.define do
  factory :profile_preference do
    profile
    preferences { { locale: "en" } }
  end
end
