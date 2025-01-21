# frozen_string_literal: true

Sequel.migration do
  up do
    report_type = %w[
      spam
      intimidation
      harassment
      minors
      against_rules
      illegal
      other
    ]

    create_enum(:report_type, report_type)
    create_table(:reports) do
      primary_key :id, type: :Bignum
      column :created_at, :timestamptz, null: false, default: Sequel::CURRENT_TIMESTAMP
      column :updated_at, :timestamptz, null: false, default: Sequel::CURRENT_TIMESTAMP
      column :message_ids, "bigint[]", default: []
      column :comment, :text
      column :type, :report_type, null: false
      foreign_key :profile_id, :profiles, null: false, type: :uuid
      foreign_key :target_profile_id, :profiles, null: false, type: :uuid
    end
  end
  down do
    drop_table(:reports)
    drop_enum(:report_type)
  end
end
