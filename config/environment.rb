# frozen_string_literal: true

require_relative "environment_config"

# This module is responsible for checking which environment we're using (development, test and so on)
# and also in the case of test or development, loading the environment variables from .env files
module Environment
  class << self
    # Based on +current+, will decide which .env files to load using the +dotenv+ gem.
    # Will do nothing if not development or test
    #
    # @return [void]
    def load
      bundle_config

      if (development? || test?) && !@dotenv_loaded
        files = [".env.#{current}.local", ".env.#{current}"]
        Dotenv.load(*files)
        @dotenv_loaded = true
      end

      EnvironmentConfig.load_values
    end

    # Will load gems from bundle
    # @return (see Bundler.require)
    def bundle_config
      return if @bundle_loaded

      load_from = %i[default]
      load_from << :development if development?
      load_from << :test if test?
      Bundler.require(*load_from)
      @bundle_loaded = true
    end

    # Current will check the environment variables and decide the current environment.
    # It memoizes the result, so this will be done once per app initialization.
    #
    # @return [Symbol]
    def current
      @current ||= begin
        e = ENV["APP_ENV"] || ENV["RACK_ENV"] || "development"
        if e == "development"
          :development
        elsif e == "test"
          :test
        else
          e.to_sym
        end
      end
    end

    # @return [Boolean]
    def development?
      current == :development
    end

    # @return [Boolean]
    def test?
      current == :test
    end
  end
end
