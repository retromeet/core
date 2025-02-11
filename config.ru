# frozen_string_literal: true

require_relative "config/environment"

Environment.load

require_relative "config/zeitwerk"
require_relative "config/shrine"
require_relative "config/mail"
require_relative "config/locales"

use Rack::CommonLogger
use API::RodauthMiddleware

run API::Base
