# frozen_string_literal: true

class Message < Sequel::Model
  many_to_one :conversation
end

FactoryBot.define do
  factory :message do
    content { Faker::Lorem.paragraph }
  end
end
