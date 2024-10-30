# frozen_string_literal: true

class AccountStatus < Sequel::Model
  class << self
    def verified
      @verified ||= AccountStatus.where(name: "Verified").first
    end
  end
end

FactoryBot.define do
  factory :account_status do
    name { "status" }
  end
end
