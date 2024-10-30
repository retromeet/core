# frozen_string_literal: true

class Account < Sequel::Model
  many_to_one :account_status, key: :status_id
  one_to_one :account_password_hash
  one_to_one :account_information
end

FactoryBot.define do
  factory :account do
    transient do
      password { "password" }
      account_information { {} }
    end
    email { Faker::Internet.email }
    account_status { AccountStatus.verified }
    after(:create) do |account, evaluator|
      create(:account_password_hash, account:, password: evaluator.password)
      create(:account_information, account:, **evaluator.account_information)
    end
  end
end
