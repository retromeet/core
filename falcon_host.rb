#!/usr/bin/env falcon-host
# frozen_string_literal: true

require "falcon/environment/rack"
require "falcon/environment/supervisor"

hostname = File.basename(__dir__)
port = ENV["PORT"] || 3000
service hostname do
  include Falcon::Environment::Rack

  preload "preload.rb"

  # TODO: Does it make sense to allow falcon http2 directly? Currently reverse proxy needed.
  endpoint do
    Async::HTTP::Endpoint.parse("http://localhost:#{port}").with(protocol: Async::HTTP::Protocol::HTTP11)
  end
end

service "supervisor" do
  include Falcon::Environment::Supervisor
end
