# frozen_string_literal: true

class Profile < Sequel::Model
  many_to_one :account
  many_to_one :location
end
FactoryBot.define do
  factory :profile do
    account
    location
    about_me { Faker::Lorem.paragraph }
    birth_date { Date.new(1985, 8, 5) }
    genders { %w[questioning man] }
    orientations { %w[bisexual fluid] }
    languages { %w[eng por spa] }
    relationship_status { "partnered" }
    relationship_type { "non_monogamous" }
    tobacco { "never" }
    marijuana { "sometimes" }
    alcohol { "sometimes" }
    other_recreational_drugs { "sometimes" }
    pets { "have" }
    wants_pets { "maybe" }
    kids { "have_not" }
    wants_kids { "do_not_want_any" }
    religion { "atheism" }
    religion_importance { "not_important" }
    display_name { Faker::Twitter.screen_name }
    created_at { Time.now }
    pronouns { "They/them" }

    trait :with_picture do
      picture { image_data }
    end

    factory :profile_with_picture, traits: %i[with_picture]
  end
end
