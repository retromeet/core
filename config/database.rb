# frozen_string_literal: true

# Contains the methods to connect to the database
module Database
  class << self
    # We use Falcon and need fiber concurrency for Sequel to behave well
    Sequel.extension :fiber_concurrency unless Environment.test?

    # Connects to the database if no connection exists
    #
    # @raise (see .pgsql_host)
    # @raise (see .pgsql_database)
    # @raise (see .connection_options)
    # @return [Sequel::Database]
    def connection
      @connection ||= begin
        c = Sequel.connect(connection_string, **connection_options)
        logger = Logger.new($stdout, level: Logger::INFO)
        logger.level = Logger::DEBUG if Environment.test? || Environment.development?
        c.logger = logger
        c
      end
    end

    # Connects to the database with the special password user. Should only be used for the database setup.
    #
    # @raise (see .pgsql_host)
    # @raise (see .pgsql_database)
    # @raise (see .connection_options)
    # @return [Sequel::Database]
    def ph_connection
      Sequel.connect(connection_string, ph_connection_options)
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

      # @raise [KeyError] If the PGSQL_USERNAME enviroment variable is not filled
      # @return [Hash{Symbol=>Object}]
      def connection_options
        connection_options = { extensions: %i[pg_array pg_enum] }
        connection_options[:user] = ENV.fetch("PGSQL_USERNAME")
        connection_options[:password] = ENV["PGSQL_PASSWORD"] if ENV["PGSQL_PASSWORD"]
        connection_options[:max_connections] = 1 if Environment.test?
        connection_options
      end

      # @raise [KeyError] If the PGSQL_PASSWORD_USERNAME enviroment variable is not filled
      # @return [Hash{Symbol=>Object}]
      def ph_connection_options
        connection_options = {}
        connection_options[:user] = ENV.fetch("PGSQL_PASSWORD_USERNAME")
        connection_options[:password] = ENV["PGSQL_PASSWORD"] if ENV["PGSQL_PASSWORD"]
        connection_options
      end
  end
end
