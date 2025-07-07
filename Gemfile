# frozen_string_literal: true

source "https://rubygems.org"

ruby file: ".ruby-version"

# The API framework-related gems
gem "grape", "~> 2.4"
gem "grape-entity", "~> 1.0"
gem "grape-swagger"
gem "grape-swagger-entity"

gem "falcon" # The app server

gem "i18n" # Used for translating strings in the views

gem "bcrypt" # Used by rodauth for password hashing
gem "jwt" # Used by rodauth jwt
gem "roda" # Used for the authorization/authentication as middleware
gem "rodauth" # Used for login
gem "rodauth-i18n" # Uses the i18n gem for rodauth's "translatable_method"s
gem "rodauth-oauth" # Provides the oauth implementation to rodauth
# gem "rotp" # Used by rodauth otp feature
# gem "rqrcode" # Used by rodauth otp feature

gem "mail" # Used by rodauth to send transactional emails

# Database-related gems
gem "pg" # Postgresql driver used by Sequel
gem "sequel" # The base gem for accessing the database layer

# View-related gems
gem "haml" # To use haml as the rendering engine
gem "sass-embedded" # To serve .scss
gem "tilt" # Used by roda to serve the views

# CLI-related gems
gem "pastel" # Used for coloring the output of rake tasks
gem "rake" # CLI for common tasks such as database creation and so on

gem "zeitwerk" # Used for autoloading the code in the API

gem "async-http" # Used for making requests towards other APIs

gem "address_composer", # Used for taking components of the address from the Photon/Nominatim response and making it into a user-friendly address
    github: "retromeet/address_composer", submodules: true # A fork that only deals with symbols for reduced memory usage
gem "mustache",
    github: "HParker/mustache", ref: "28cb499d4744131f9579b14890787068cff2450d" # solves the mutable strings warnings. is a dep of address_composer and should be removed when a new version is cut

gem "shrine" # Used for file uploads

gem "aws-sdk-s3", "~> 1.192" # For S3-like storage in Shrine
gem "rexml" # needed by S3

group :development, :test do
  gem "dotenv" # Used to load environment variables from .env files

  gem "letter_opener" # Used to display email in the development environment instead of sending

  gem "rerun", require: false # Used to reload the server when code changes

  gem "debug" # Used for calling debugger from the code

  # Code formatting and hooks
  gem "lefthook", require: false # Used to make git hooks available between dev machines
  gem "pronto", "~> 0.11", require: false # pronto analyzes code on changed code only
  gem "pronto-rubocop", require: false # pronto-rubocop extends pronto for rubocop

  gem "rubocop", require: false # A static code analyzer and formatter
  gem "rubocop-capybara", require: false # Extension for capybara tests
  gem "rubocop-factory_bot", require: false # A rubocop extension for factory bot
  gem "rubocop-minitest", require: false # A rubocop extension for minitest
  gem "rubocop-performance", require: false # A rubocop extension with performance suggestions
  gem "rubocop-rake", require: false # A rubocop extension for Rakefiles
  gem "rubocop-sequel", require: false # A rubocop extension for Sequel
  gem "rubocop-yard", require: false # A rubocop extension for yard documentation
end

group :test do
  gem "minitest" # The test framework
  gem "minitest-hooks", require: "minitest/hooks/default" # Adds before(:all) hooks to improve test time
  gem "rack-test" # Adds functionality to test Rack apps

  gem "capybara"
  gem "falcon-capybara"
  gem "selenium-webdriver"

  gem "database_cleaner-sequel" # Cleans the database between tests

  gem "committee", # Used to test the swagger documentation in the tests
      github: "retromeet/committee", ref: "ad2c31011987b2db935b6c950bfeccc501d65fba" # This adds extra validation to OpenAPI 2, should be replaced as soon as new version is cut

  gem "factory_bot" # makes it easier to create objects for tests
  gem "faker" # provides fake data for tests
  gem "mocha", require: "mocha/minitest" # adds mocking capabilities
  gem "webmock", require: "webmock/minitest" # Used for avoiding real requests in the test enviroment
end
