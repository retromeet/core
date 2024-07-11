# frozen_string_literal: true

# Contains the methods to connect to the database
module Database
  class << self
    # Connects to the database if no connection exists
    #
    # @raise (see .pgsql_host)
    # @raise (see .pgsql_database)
    # @return [Sequel::Database]
    def connection
      @connection ||= Sequel.connect(connection_string, **connection_options)
    end

    private

      # @return [String]
      def connection_string
        "postgres://#{pgsql_host}/#{pgsql_database}"
      end

      # @raise [KeyError] If the PGSQL_HOST enviroment variable is not filled
      # @return [String]
      def pgsql_host
        ENV.fetch("PGSQL_HOST")
      end

      # @raise [KeyError] If the PGSQL_DATABASE enviroment variable is not filled
      # @return [String]
      def pgsql_database
        ENV.fetch("PGSQL_DATABASE")
      end

      # @return [Hash{Symbol=>Object}]
      def connection_options
        connection_options = {}
        connection_options[:user] = ENV["PGSQL_USERNAME"] if ENV["PGSQL_USERNAME"]
        connection_options[:password] = ENV["PGSQL_PASSWORD"] if ENV["PGSQL_PASSWORD"]
        connection_options
      end
  end
end
