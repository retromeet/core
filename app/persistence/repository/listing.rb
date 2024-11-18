# frozen_string_literal: true

module Persistence
  module Repository
    # Contains database logic around the account listing
    module Listing
      class << self
        # Returns accounts that are near the requested Account
        # will paginate results with min_account_id
        # @param account_id [Integer] The account id of the logged-in user to show nearby profiles for
        # @param min_account_id [Integer, nil] Used for pagination, it should be the id of the last account seen
        # @param max_distance_in_meters [Integer] The max distance to show profiles
        # @return [Hash{Symbol => Object}] A hash containing the nearby accounts
        def nearby(account_id:, min_account_id: nil, max_distance_in_meters: 5_000)
          profile_location = Persistence::Repository::Account.profile_location(account_id:)

          location_subquery = locations.select(Sequel.lit("geom::geography <-> ?::geography", profile_location).as(:dist))
                                       .select_append(:id, Sequel[:display_name].as(:location_display_name))
                                       .where(Sequel.function(:ST_DWithin, Sequel.lit("geom::geography"), Sequel.lit("?::geography", profile_location), max_distance_in_meters))
                                       .order(:dist)
          accounts = account_informations.inner_join(location_subquery, id: :location_id)
                                         .select(:display_name, :account_id, :birth_date, :genders, :orientations, :relationship_status, :location_display_name, Sequel[:dist].as(:location_distance))
                                         .exclude(Sequel[:account_informations][:account_id] => account_id)
          accounts.where { account_id > min_account_id } if min_account_id
          accounts.to_a
        end

        private

          # @return [Sequel::Postgres::Dataset]
          def locations
            Database.connection[:locations]
          end

          # @return [Sequel::Postgres::Dataset]
          def account_informations
            Database.connection[:account_informations]
          end
      end
    end
  end
end
