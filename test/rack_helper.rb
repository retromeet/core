# frozen_string_literal: true

module RackHelper
  include Rack::Test::Methods

  def app
    Rack::Builder.parse_file("config.ru")
  end

  BadLoginError = Class.new(StandardError)
  def login(login:, password:)
    header "content-type", "application/json"
    response = post("/login", { login:, password: }.to_json)
    raise BadLoginError unless response.ok?

    response.headers["authorization"]
  end

  def authorized_get(authorization, *)
    header "authorization", authorization
    header "content-type", "application/json"
    header "accept", "application/json"
    get(*)
  end

  def authorized_post(authorization, *)
    header "authorization", authorization
    header "content-type", "application/json"
    header "accept", "application/json"
    post(*)
  end
end
