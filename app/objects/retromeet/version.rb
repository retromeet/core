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
        ""
      end

      # The prerelease name, takes the +RETROMEET_VERSION_PRERELEASE+ environment variable into consideration
      # @return [String]
      def prerelease
        EnvironmentConfig.retromeet_version_prerelease.presence || default_prerelease
      end

      # The build metadata, should be used to indicate a fork or other special build condition
      # Takes the +RETROMEET_VERSION_METADATA+ environment variable into consideration
      # @return [String,nil]
      def build_metadata
        EnvironmentConfig.retromeet_version_metadata
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
        @user_agent ||= "RetroMeet-core/#{Version} (async-http #{Async::HTTP::VERSION}; +#{RetroMeet::Url})"
      end
    end
  end
end
