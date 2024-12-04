# frozen_string_literal: true

require_relative "config/environment"

Environment.load

require_relative "config/zeitwerk"
require_relative "config/shrine"

use Rack::CommonLogger
use API::RodauthMiddleware

run API::Base
