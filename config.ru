# frozen_string_literal: true

require_relative "preload" unless defined?(EnvironmentConfig)

Rack::Request.ip_filter = ->(ip) { EnvironmentConfig.rack_trusted_ips_re.match?(ip) }
use Rack::CommonLogger
use API::RodauthMiddleware

run API::Base
