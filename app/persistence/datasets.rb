# frozen_string_literal: true

module Persistence
  # This module contains the datasets (tables) using the database connection.
  # This makes it easier to have the datasets being called the same in the different repositories
  module Datasets
    private

      # @return [Sequel::Postgres::Dataset]
      def accounts
        Database.connection[:accounts]
      end

      # @return [Sequel::Postgres::Dataset]
      def locations
        Database.connection[:locations]
      end

      # @return [Sequel::Postgres::Dataset]
      def profiles
        Database.connection[:profiles]
      end

      # @return [Sequel::Postgres::Dataset]
      def profile_blocks
        Database.connection[:profile_blocks]
      end

      # @return [Sequel::Postgres::Dataset]
      def profile_preferences
        Database.connection[:profile_preferences]
      end

      # @return [Sequel::Postgres::Dataset]
      def conversations
        Database.connection[:conversations]
      end

      # @return [Sequel::Postgres::Dataset]
      def messages
        Database.connection[:messages]
      end

      # @return [Sequel::Postgres::Dataset]
      def reports
        Database.connection[:reports]
      end
  end
end
