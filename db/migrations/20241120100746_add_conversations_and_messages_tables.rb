# frozen_string_literal: true

Sequel.migration do
  up do
    create_table(:conversations) do
      column :id, :uuid, null: false, default: Sequel.lit("uuid_generate_v7()"), primary_key: true
      foreign_key :profile1_id, :profiles, null: false, type: :uuid
      foreign_key :profile2_id, :profiles, null: false, type: :uuid
      column :created_at, :timestamptz, null: false, default: Sequel::CURRENT_TIMESTAMP
      column :profile1_last_seen_at, :timestamptz
      column :profile2_last_seen_at, :timestamptz

      index %i[profile1_id profile2_id], unique: true
    end

    create_enum :sender_values, %i[profile1 profile2]

    create_table(:messages) do
      primary_key :id
      foreign_key :conversation_id, :conversations, null: false, type: :uuid
      column :sender, :sender_values, null: false
      column :sent_at, :timestamptz, null: false, default: Sequel::CURRENT_TIMESTAMP
      column :content, :text, null: false
    end
  end

  down do
    drop_table :messages
    drop_enum :sender_values
    drop_table :conversations
  end
end
