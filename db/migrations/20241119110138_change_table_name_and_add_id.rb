# frozen_string_literal: true

Sequel.migration do
  up do
    rename_table(:account_informations, :profiles)
    alter_table(:profiles) do
      add_column :id, :uuid, null: false, default: Sequel.lit("uuid_generate_v7()")
      drop_constraint(:account_informations_pkey)
      add_primary_key(%i[id])
    end
    run "UPDATE profiles set id = uuid_timestamptz_to_v7(created_at)"
  end
  down do
    rename_table(:profiles, :account_informations)
    alter_table(:account_informations) do
      drop_constraint(:profiles_pkey)
      add_primary_key(%i[account_id])
      drop_column :id
    end
  end
end
