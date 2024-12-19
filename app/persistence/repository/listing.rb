# frozen_string_literal: true

module Persistence
  module Repository
    # Contains database logic around the account listing
    module Listing
      extend Datasets

      class << self
        # Returns accounts that are near the requested Account
        # will paginate results with min_account_id
        # @param id [Integer] The profile id of the logged-in user to show nearby profiles for, it should be an UUID
        # @param min_account_id [Integer, nil] Used for pagination, it should be the id of the last account seen
        # @param max_distance_in_meters [Integer] The max distance to show profiles
        # @return [Hash{Symbol => Object}] A hash containing the nearby accounts
        def nearby(id:, min_account_id: nil, max_distance_in_meters: 5_000)
          profile_location = Persistence::Repository::Account.profile_location(id:)

          location_subquery = locations.select(Sequel.lit("geom::geography <-> ?::geography", profile_location).as(:dist))
                                       .select_append(:id, Sequel[:display_name].as(:location_display_name))
                                       .where(Sequel.function(:ST_DWithin, Sequel.lit("geom::geography"), Sequel.lit("?::geography", profile_location), max_distance_in_meters))
                                       .order(:dist)

          blocked_profiles_query = profile_blocks.where(profile_id: id)
                                                 .select(:target_profile_id)

          accounts = profiles.inner_join(location_subquery, id: :location_id)
                             .select(:display_name, Sequel[:profiles][:id], :birth_date, :genders, :orientations, :relationship_status, :location_display_name, Sequel[:dist].as(:location_distance))
                             .exclude(Sequel[:profiles][:id] => id)
                             .exclude(Sequel[:profiles][:id] => blocked_profiles_query)

          accounts.where { account_id > min_account_id } if min_account_id

          accounts.to_a
        end
      end
    end
  end
end
