# frozen_string_literal: true

require_relative "preload" unless defined?(EnvironmentConfig)

use Rack::CommonLogger
use API::RodauthMiddleware

run API::Base
