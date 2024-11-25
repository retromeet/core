# frozen_string_literal: true

class Message < Sequel::Model
  many_to_one :conversation
end

FactoryBot.define do
  factory :message do
    conversation
    sender { "profile1" }
    content { Faker::Lorem.paragraph }
  end
end
