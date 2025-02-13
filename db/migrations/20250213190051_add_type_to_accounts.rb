# frozen_string_literal: true

Sequel.migration do
  up do
    account_type = %w[
      regular
      admin
    ]
    create_enum(:account_type, account_type)
    alter_table(:accounts) do
      add_column :type, :account_type, null: false, default: "regular"
    end
  end
  down do
    alter_table(:accounts) do
      drop_column :type
    end
    drop_enum(:account_type)
  end
end
