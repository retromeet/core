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

        private

          # @return [Sequel::Postgres::Dataset]
          def account_informations
            Database.connection[:account_informations]
          end
      end
    end
  end
end
