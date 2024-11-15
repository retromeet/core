# frozen_string_literal: true

module Persistence
  module Repository
    # Contains database logic around the account listing
    module Listing
      class << self
        def nearby(account_id:, distance_in_meters: 5_000)
          profile_location = Persistence::Repository::Account.profile_location(account_id:)

          location_subquery = locations.select(Sequel.lit("geom::geography <-> ?::geography", profile_location).as(:dist))
                                       .select_append(:id, Sequel[:display_name].as(:location_display_name))
                                       .where(Sequel.function(:ST_DWithin, Sequel.lit("geom::geography"), Sequel.lit("?::geography", profile_location), distance_in_meters))
                                       .order(:dist)
          pp location_subquery.to_a
          account_informations.inner_join(location_subquery, id: :location_id)
                              .select(:display_name, :account_id, :birth_date, :genders, :orientations, :relationship_status, :location_display_name)
                              .exclude(Sequel[:account_informations][:account_id] => account_id)
                              .to_a
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
