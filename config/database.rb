# frozen_string_literal: true

# Contains the methods to connect to the database
module Database
  class << self
    # We use Falcon and need fiber concurrency for Sequel to behave well
    Sequel.extension :fiber_concurrency unless Environment.test?
    # Used for some jsonb operations with locations
    Sequel.extension :pg_json_ops

    # Connects to the database if no connection exists
    #
    # @raise (see .pgsql_host)
    # @raise (see .pgsql_database)
    # @raise (see .connection_options)
    # @return [Sequel::Database]
    def connection
      @connection ||= begin
        c = Sequel.connect(connection_string, **connection_options)
        c.sql_log_level = :debug
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
        "postgres://#{EnvironmentConfig.pgsql_host}/#{EnvironmentConfig.pgsql_database}"
      end

      # @raise [KeyError] If the PGSQL_USERNAME enviroment variable is not filled
      # @return [Hash{Symbol=>Object}]
      def connection_options
        connection_options = { extensions: %i[pg_array pg_enum pg_json] }
        connection_options[:user] = EnvironmentConfig.pgsql_username
        connection_options[:password] = EnvironmentConfig.pgsql_password if EnvironmentConfig.pgsql_password
        connection_options[:max_connections] = 1 if Environment.test?
        connection_options
      end

      # @raise [KeyError] If the PGSQL_PH_USERNAME enviroment variable is not filled
      # @return [Hash{Symbol=>Object}]
      def ph_connection_options
        connection_options = {}
        connection_options[:user] = EnvironmentConfig.pgsql_ph_username
        connection_options[:password] = EnvironmentConfig.pgsql_ph_password if EnvironmentConfig.pgsql_ph_password
        connection_options
      end
  end
end
