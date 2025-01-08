# frozen_string_literal: true

Sequel.migration do
  change do
    create_table(:profile_blocks) do
      primary_key :id
      column :created_at, :timestamptz, null: false, default: Sequel::CURRENT_TIMESTAMP
      foreign_key :profile_id, :profiles, null: false, type: :uuid
      foreign_key :target_profile_id, :profiles, null: false, type: :uuid
      index %i[profile_id target_profile_id], unique: true
    end
  end
end
