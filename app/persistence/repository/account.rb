# frozen_string_literal: true

module Persistence
  module Repository
    # Contains database logic around accounts
    module Account
      class << self
        # Returns profile information for a given account
        #
        # @param account_id [Integer] An id for an account
        # @return [Hash{Symbol => Object}] A record containing +account_id+, +created_at+ and +display_name+
        def profile_info(account_id:)
          account_informations.where(account_id:).first
        end

        # Returns basic profile information for a given account
        #
        # @param account_id [Integer] An id for an account
        # @return [Hash{Symbol => Object}] A record containing +account_id+, +created_at+ and +display_name+
        def basic_profile_info(account_id:)
          account_informations.where(account_id:).select(:created_at, :display_name, :account_id).first
        end

        # Updates the profile information for a given account
        # Does not validate argument names passed to +args+, so if not validated before-hand can raise an exception
        # @param account_id (see #profile_info)
        # @param args [Hash{Symbol => Object}] A hash containing the fields to be updated. Will not be verified for validity.
        # @return [void]
        def update_profile_info(account_id:, **args)
          account_informations.where(account_id:).update(args)
        end

        private

          # @return [Sequel::Postgres::Dataset]
          def account_informations
            Database.connection[:account_informations]
          end
      end
    end
  end
end
