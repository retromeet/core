# frozen_string_literal: true

class OauthGrant < Sequel::Model
  many_to_one :account
  many_to_one :oauth_application
end

FactoryBot.define do
  factory :oauth_grant do
    account
    oauth_application
    type { "authorization_code" }
    code { "CODE" }
    expires_in { Time.now + (60 * 5) }
    redirect_uri { oauth_application.redirect_uri }
    scopes { oauth_application.scopes }
  end
end
