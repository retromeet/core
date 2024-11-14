# frozen_string_literal: true

class Location < Sequel::Model
end

FactoryBot.define do
  factory :location do
    transient do
      latitude { Faker::Address.latitude }
      longitude { Faker::Address.longitude }
    end
    display_name { Sequel.pg_jsonb_wrap({ en: "Reception zone" }) }
    country_code { Faker::Address.country_code.downcase }
    osm_id { rand(1..10_000) }
    geom { Sequel.lit("POINT(#{longitude}, #{latitude})::geometry") }
  end
end
