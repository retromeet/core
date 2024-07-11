# frozen_string_literal: true

source "https://rubygems.org"

ruby file: ".ruby-version"

# Database-related gems
gem "pg" # Postgresql driver used by Sequel
gem "sequel" # The base gem for accessing the database layer

# CLI-related gems
gem "rake" # CLI for common tasks such as database creation and so on

group :development, :test do
  gem "dotenv" # Used to load environment variables from .env files

  gem "rubocop", require: false # A static code analyzer and formatter
  gem "rubocop-performance", require: false # A rubocop extension with performance suggestions
  gem "rubocop-sequel", require: false # A rubocop extension for Sequel
  gem "rubocop-yard", require: false # A rubocop extension for yard documentation
end
