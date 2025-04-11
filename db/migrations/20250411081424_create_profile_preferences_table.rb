# frozen_string_literal: true

Sequel.migration do
  change do
    create_table(:profile_preferences) do
      primary_key :id, type: :Bignum
      foreign_key :profile_id, :profiles, type: "uuid", null: false, key: %i[id]
      column :preferences, "jsonb", null: false
    end
  end
end
