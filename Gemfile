# frozen_string_literal: true

source "https://rubygems.org"

ruby file: ".ruby-version"

# The API framework-related gems
gem "grape", "< 2.2" # Temporary, until https://github.com/ruby-grape/grape-swagger/issues/939 is fixed
gem "grape-entity", "~> 1.0"
gem "grape-swagger"
gem "grape-swagger-entity"

gem "falcon" # The app server

gem "bcrypt" # Used by rodauth for password hashing
gem "jwt" # Used by rodauth jwt
gem "roda" # Used for the login middleware
gem "rodauth" # Used for login
# gem "rotp" # Used by rodauth otp feature
# gem "rqrcode" # Used by rodauth otp feature

# Database-related gems
gem "pg" # Postgresql driver used by Sequel
gem "sequel" # The base gem for accessing the database layer

# CLI-related gems
gem "pastel" # Used for coloring the output of rake tasks
gem "rake" # CLI for common tasks such as database creation and so on

group :development, :test do
  gem "dotenv" # Used to load environment variables from .env files

  gem "rerun", require: false # Used to reload the server when code changes

  gem "debug" # Used for calling debugger from the code

  # Code formatting and hooks
  gem "lefthook", require: false # Used to make git hooks available between dev machines
  gem "pronto", "~> 0.11", require: false # pronto analyzes code on changed code only
  gem "pronto-rubocop", require: false # pronto-rubocop extends pronto for rubocop

  gem "rubocop", require: false # A static code analyzer and formatter
  gem "rubocop-performance", require: false # A rubocop extension with performance suggestions
  gem "rubocop-rake", require: false # A rubocop extension for Rakefiles
  gem "rubocop-sequel", require: false # A rubocop extension for Sequel
  gem "rubocop-yard", require: false # A rubocop extension for yard documentation
end
