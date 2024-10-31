# frozen_string_literal: true

module RetroMeet
  # This module contains functions to build the retromeet core version to be used around programatically
  # Should be modified when releasing to indicate the proper versions
  module Version
    class << self
      # The major part of the version
      # @return [Integer]
      def major
        0
      end

      # The minor part of the version
      # @return [Integer]
      def minor
        1
      end

      # The patch part of the version
      # @return [Integer]
      def patch
        0
      end

      # The default prerelease name
      # @return [String]
      def default_prerelease
        "alpha.1"
      end

      # The prerelease name, takes the +RETROMEET_VERSION_PRERELEASE+ environment variable into consideration
      # @return [String]
      def prerelease
        ENV["RETROMEET_VERSION_PRERELEASE"].presence || default_prerelease
      end

      # The build metadata, should be used to indicate a fork or other special build condition
      # Takes the +RETROMEET_VERSION_METADATA+ environment variable into consideration
      # @return [String,nil]
      def build_metadata
        ENV.fetch("MASTODON_VERSION_METADATA", nil)
      end

      # @return [Array<String>]
      def to_a
        [major, minor, patch].compact
      end

      # @return [String]
      def to_s
        components = [to_a.join(".")]
        components << "-#{prerelease}" if prerelease.present?
        components << "+#{build_metadata}" if build_metadata.present?
        components.join
      end

      # @return [String]
      def user_agent
        # TODO: (renatolond, 2024-10-31): properly build the address of the server
        @user_agent ||= "RetroMeet-core/#{Version} (async-http #{Async::HTTP::VERSION}; +http#{false ? "s" : ""}://localhost:3000/)"
      end
    end
  end
end
