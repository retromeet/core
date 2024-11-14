# frozen_string_literal: true

class Location < Sequel::Model
end

FactoryBot.define do
  factory :location do
    transient do
      latitude { Faker::Address.latitude }
      longitude { Faker::Address.longitude }
    end
    display_name { Faker::Address.full_name }
    country_code { Faker::Address.country_code }
    osm_id { rand(1..10_000) }
    geom { Sequel.lit("POINT(#{longitude}, #{latitude})::geometry") }
  end
end
