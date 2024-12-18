# frozen_string_literal: true

class ProfileBlock < Sequel::Model
  many_to_one :profile, key: :profile_id, class: "Profile"
  many_to_one :target_profile, key: :target_profile_id, class: "Profile"
end

FactoryBot.define do
  factory :profile_block do
    profile factory: :profile
    target_profile factory: :profile
    created_at { Time.now }
  end
end
