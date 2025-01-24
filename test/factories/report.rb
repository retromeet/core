# frozen_string_literal: true

class Report < Sequel::Model
  many_to_one :profile, key: :profile_id, class: "Profile"
  many_to_one :target_profile, key: :target_profile_id, class: "Profile"
end

FactoryBot.define do
  factory :report do
    profile factory: :profile
    target_profile factory: :profile
    comment { "Advertising some products" }
    type { "spam" }
  end
end
