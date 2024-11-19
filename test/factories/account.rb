# frozen_string_literal: true

class Account < Sequel::Model
  many_to_one :account_status, key: :status_id
  one_to_one :account_password_hash
  one_to_one :profile
end

FactoryBot.define do
  factory :account do
    transient do
      password { "password" }
      profile { {} }
    end
    email { Faker::Internet.email }
    account_status { AccountStatus.verified }
    after(:create) do |account, evaluator|
      create(:account_password_hash, account:, password: evaluator.password)
      create(:profile, account:, **evaluator.profile)
    end
  end
end
