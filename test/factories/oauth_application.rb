# frozen_string_literal: true

class OauthApplication < Sequel::Model
  many_to_one :account
end

FactoryBot.define do
  factory :oauth_application do
    transient do
      client_secret_plain { "CLIENT_SECRET" }
      registration_access_token_plain { "CLIENT_TOKEN" }
    end
    account
    name { "Foo" }
    description { "this is a foo" }
    homepage_url { "https://example.com" }
    redirect_uri { "https://example.com/callback" }
    client_id { "CLIENT_ID" }
    client_secret { BCrypt::Password.create(client_secret_plain, cost: BCrypt::Engine::MIN_COST) }
    registration_access_token { BCrypt::Password.create(registration_access_token_plain, cost: BCrypt::Engine::MIN_COST) }
    scopes { "profile" }
  end
end
