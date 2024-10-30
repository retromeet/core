# frozen_string_literal: true

class AccountPasswordHash < Sequel::Model
  many_to_one :account, key: :id
end

FactoryBot.define do
  factory :account_password_hash do
    transient do
      password { "password" }
    end
    account
    password_hash { puts password; BCrypt::Password.create(password, cost: BCrypt::Engine::MIN_COST) }
  end
end
