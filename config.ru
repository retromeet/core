# frozen_string_literal: true

require_relative "config/environment"

Environment.load

require_relative "app/rodauth_middleware"

use Rack::CommonLogger
use RodauthMiddleware

require_relative "app/api"

run API
