# frozen_string_literal: true

require "dry-types"

# This module contains all configuration that is loaded from ENV variables to be available to the rest of the app.
# It is loaded here so that if a environment variable is needed at runtime, it will fail fast, and not eventually fail at runtime when needed.
module EnvironmentConfig
  # Dry types is a module that contains the dry-types param types used below for casting booleans
  module DryTypes
    include ::Dry.Types(:params)
  end

  class << self
    # @raise [Dry::Types::CoercionError] If the value of the variable cannot be coerced correctly
    # @return [Boolean]
    def use_https?
      @use_https ||= Environment.current == :production || DryTypes::Params::Bool[ENV.fetch("LOCAL_HTTPS", false)]
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

    # @raise [Dry::Types::CoercionError] If the value of the variable cannot be coerced correctly
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
    def shrine_s3_cloudfront_host
      @shrine_s3_cloudfront_host ||= ENV.fetch("S3_CLOUDFRONT_HOST", nil)
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

    # @raise [Dry::Types::CoercionError] If the value of the variable cannot be coerced correctly
    # @return [Boolean]
    def use_smtp?
      DryTypes::Params::Bool[ENV.fetch("USE_SMTP", false)]
    end

    # @return [String, nil]
    def smtp_port
      @smtp_port ||= ENV.fetch("SMTP_PORT", nil)
    end

    # @return [String, nil]
    def smtp_server
      @smtp_server ||= ENV.fetch("SMTP_SERVER", nil)
    end

    # @return [String, nil]
    def smtp_login
      @smtp_login ||= ENV.fetch("SMTP_LOGIN", nil)
    end

    # @return [String, nil]
    def smtp_password
      @smtp_password ||= ENV.fetch("SMTP_PASSWORD", nil)
    end

    # @return [String, nil]
    def smtp_domain
      @smtp_domain ||= ENV.fetch("SMTP_DOMAIN", nil)
    end

    # @return [String, nil]
    def smtp_auth_method
      @smtp_auth_method ||= ENV.fetch("SMTP_AUTH_METHOD", nil)
    end

    # @return [String, nil]
    def smtp_ca_file
      @smtp_ca_file ||= ENV.fetch("SMTP_CA_FILE", nil)
    end

    # @return [String, nil]
    def smtp_openssl_verify_mode
      @smtp_openssl_verify_mode ||= ENV.fetch("SMTP_OPENSSL_VERIFY_MODE", nil)
    end

    # @return [Boolean,nil]
    def smtp_tls
      @smtp_tls ||= ENV["SMTP_TLS"].present? ? DryTypes::Params::Bool[ENV.fetch("SMTP_TLS", false)] : nil
    end

    # @return [Boolean,nil]
    def smtp_ssl
      @smtp_ssl ||= ENV["SMTP_SSL"].present? ? DryTypes::Params::Bool[ENV.fetch("SMTP_SSL", false)] : nil
    end

    # @return [String, nil]
    def smtp_enable_starttls
      @smtp_enable_starttls ||= ENV.fetch("SMTP_ENABLE_STARTTLS", nil)
    end

    # @return [Boolean]
    def smtp_enable_starttls_auto
      @smtp_enable_starttls_auto ||= DryTypes::Params::Bool[ENV.fetch("SMTP_ENABLE_STARTTLS_AUTO", false)]
    end

    # @return [String]
    def smtp_from_address
      @smtp_from_address ||= ENV.fetch("SMTP_FROM_ADDRESS", "notifications@localhost")
    end

    # @return [String]
    def smtp_outgoing_domain
      @smtp_outgoing_domain ||= Mail::Address.new(smtp_from_address).domain
    end

    # @return [Regexp]
    def rack_trusted_ips_re
      @rack_trusted_ips_re ||= begin
        proxy_ips = ENV.fetch("PROXY_IPS", "")
        valid_ipv4_octet = /\.(25[0-5]|2[0-4][0-9]|[01]?[0-9]?[0-9])/
        regexes = [/\A127#{valid_ipv4_octet}{3}\z/, # localhost IPv4 range 127.x.x.x, per RFC-3330
                   /\A::1\z/,                                                # localhost IPv6 ::1
                   /\Af[cd][0-9a-f]{2}(?::[0-9a-f]{0,4}){0,7}\z/i,           # private IPv6 range fc00 .. fdff
                   /\A10#{valid_ipv4_octet}{3}\z/,                           # private IPv4 range 10.x.x.x
                   /\A172\.(1[6-9]|2[0-9]|3[01])#{valid_ipv4_octet}{2}\z/,   # private IPv4 range 172.16.0.0 .. 172.31.255.255
                   /\A192\.168#{valid_ipv4_octet}{2}\z/,                     # private IPv4 range 192.168.x.x
                   /\Alocalhost\z|\Aunix(\z|:)/i]                            # localhost hostname, and unix domain sockets
        regexes += proxy_ips.split(",").map { |v| /\A#{Regexp.escape(v)}\z/ } if proxy_ips.present?
        Regexp.union(*regexes)
      end
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
        shrine_s3_cloudfront_host
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

      if use_smtp?
        smtp_port
        smtp_server
        smtp_login
        smtp_password
        smtp_domain
        smtp_auth_method
        smtp_ca_file
        smtp_openssl_verify_mode
        smtp_tls
        smtp_ssl
        smtp_enable_starttls
        smtp_enable_starttls_auto
        smtp_from_address
        smtp_outgoing_domain
      end

      rack_trusted_ips_re
    end
  end
end
