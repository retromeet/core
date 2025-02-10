# frozen_string_literal: true

module RackHelper
  include Rack::Test::Methods

  def self.app
    app = Rack::Builder.parse_file("config.ru")
    # TODO: need a less hacky way to do this, maybe.
    app.instance_variable_get(:@app).instance_variable_get(:@mid).rodauth.configure do
      oauth_grants_token_hash_column nil
      oauth_grants_refresh_token_hash_column nil
      oauth_applications_client_secret_hash_column nil
    end
    app
  end

  def app
    RackHelper.app
  end

  def oauth_application(params = {})
    @oauth_application ||= create(:oauth_application, **params)
  end

  def set_oauth_grant_with_token(grant = oauth_grant_with_token)
    @oauth_grant_with_token = grant
  end

  def oauth_grant_with_token(account = nil)
    @oauth_grant_with_token ||= begin
      params = { token: "TOKEN", refresh_token: "REFRESH_TOKEN", code: nil }
      params[:account] = account if account
      create(:oauth_grant, **params)
    end
  end

  def set_authorization_header(grant = oauth_grant_with_token)
    header "Authorization", "Bearer #{grant.token}"
  end

  def authorized_get(*)
    set_authorization_header(oauth_grant_with_token)
    header "content-type", "application/json"
    header "accept", "application/json"
    get(*)
  end

  def authorized_post(*)
    set_authorization_header(oauth_grant_with_token)
    header "content-type", "application/json"
    header "accept", "application/json"
    post(*)
  end

  def authorized_put(*)
    set_authorization_header(oauth_grant_with_token)
    header "content-type", "application/json"
    header "accept", "application/json"
    put(*)
  end

  def authorized_delete(*)
    set_authorization_header(oauth_grant_with_token)
    header "content-type", "application/json"
    header "accept", "application/json"
    delete(*)
  end

  def json_post(*)
    header "content-type", "application/json"
    header "accept", "application/json"
    post(*)
  end
end
