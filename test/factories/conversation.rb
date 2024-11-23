# frozen_string_literal: true

class Conversation < Sequel::Model
  many_to_one :profile1, key: :profile1_id, class: "Profile"
  many_to_one :profile2, key: :profile2_id, class: "Profile"
end

FactoryBot.define do
  factory :conversation do
    profile1 factory: :profile
    profile2 factory: :profile
    profile1_last_seen_at { Time.now }
    profile2_last_seen_at { Time.now - 60 }
  end
end
