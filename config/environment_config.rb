# frozen_string_literal: true

# This module contains all configuration that is loaded from ENV variables to be available to the rest of the app.
# It is loaded here so that if a environment variable is needed at runtime, it will fail fast, and not eventually fail at runtime when needed.
module EnvironmentConfig
  class << self
    # @return [Boolean]
    def use_https?
      @use_https ||= Environment.current == :production || ENV["LOCAL_HTTPS"] == "true"
    end

    # @return [String]
    def retromeet_core_host
      @retromeet_core_host ||= ENV.fetch("LOCAL_DOMAIN") { "localhost:#{ENV.fetch("PORT", 3000)}" }
    end

    # @raise [RuntimeError] If the variable is missing
    # @return [String]
    def session_secret
      @session_secret ||= ENV.delete("SESSION_SECRET") || (raise "Missing SESSION_SECRET variable")
    end

    # @return [Array<String>]
    def photon_api_supported_languages
      @photon_api_supported_languages ||= ENV.fetch("PHOTON_SUPPORTED_LANGUAGES", "en,fr,de").split(",").freeze
    end

    # @return [String]
    def photon_api_host
      @photon_api_host ||= ENV.fetch("PHOTON_API_HOST", "https://photon.komoot.io")
    end

    # @return [String]
    def nominatim_api_host
      @nominatim_api_host ||= ENV.fetch("NOMINATIM_API_HOST", "https://nominatim.openstreetmap.org")
    end

    # @return [Boolean]
    def shrine_s3_enabled?
      @shrine_s3_enabled ||= DryTypes::Params::Bool[ENV.fetch("S3_ENABLED", false)]
    end

    # @raise (see ENV.fetch)
    # @return [String]
    def shrine_s3_bucket
      @shrine_s3_bucket ||= ENV.fetch("S3_BUCKET")
    end

    # @return [String]
    def shrine_s3_region
      @shrine_s3_region ||= ENV.fetch("S3_REGION", "eu-west-1")
    end

    # @raise (see ENV.fetch)
    # @return [String]
    def shrine_aws_access_key_id
      @shrine_aws_access_key_id ||= ENV.fetch("AWS_ACCESS_KEY_ID")
    end

    # @raise (see ENV.fetch)
    # @return [String]
    def shrine_aws_secret_access_key
      @shrine_aws_secret_access_key ||= ENV.fetch("AWS_SECRET_ACCESS_KEY")
    end

    # @return [String, nil]
    def shrine_s3_endpoint
      @shrine_s3_endpoint ||= ENV.fetch("S3_ENDPOINT", nil)
    end

    # @return [String, nil]
    def retromeet_version_prerelease
      @retromeet_version_prerelease ||= ENV.fetch("RETROMEET_VERSION_PRERELEASE", nil)
    end

    # @return [String, nil]
    def retromeet_version_metadata
      @retromeet_version_metadata ||= ENV.fetch("RETROMEET_VERSION_METADATA", nil)
    end

    # @return [String]
    def companion_application_name
      @companion_application_name ||= ENV.fetch("COMPANION_APPLICATION_NAME", "RetroMeet Web")
    end

    # @return [String]
    def companion_application_url
      @companion_application_url ||= ENV.fetch("COMPANION_APPLICATION_URL", "http://localhost:3001")
    end

    # @raise (see ENV.fetch)
    # @return [String]
    def pgsql_host
      @pgsql_host ||= ENV.fetch("PGSQL_HOST")
    end

    # @raise (see ENV.fetch)
    # @return [String]
    def pgsql_database
      @pgsql_database ||= ENV.fetch("PGSQL_DATABASE")
    end

    # @raise (see ENV.fetch)
    # @return [String]
    def pgsql_username
      @pgsql_username ||= ENV.fetch("PGSQL_USERNAME")
    end

    # @return [String, nil]
    def pgsql_password
      @pgsql_password ||= ENV.fetch("PGSQL_PASSWORD", nil)
    end

    # @raise (see ENV.fetch)
    # @return [String]
    def pgsql_ph_username
      @pgsql_ph_username ||= ENV.fetch("PGSQL_PH_USERNAME")
    end

    # @return [String, nil]
    def pgsql_ph_password
      @pgsql_ph_password ||= ENV.fetch("PGSQL_PH_PASSWORD", nil)
    end

    # Calls all the functions in the module so that any missing variables fail early
    # @raise [KeyError] If any of the variables is missing the keys
    # @raise [RuntimeError] on any other errors
    def load_values
      use_https?

      retromeet_core_host

      session_secret

      photon_api_supported_languages
      photon_api_host

      nominatim_api_host

      if shrine_s3_enabled?
        shrine_s3_bucket
        shrine_s3_region
        shrine_aws_access_key_id
        shrine_aws_secret_access_key
        shrine_s3_endpoint
      end

      retromeet_version_prerelease
      retromeet_version_metadata

      companion_application_name
      companion_application_url

      pgsql_database
      pgsql_host
      pgsql_username
      pgsql_password
      pgsql_ph_username
      pgsql_ph_password
    end
  end
end
