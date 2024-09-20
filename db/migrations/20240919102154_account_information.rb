# frozen_string_literal: true

Sequel.migration do
  change do
    create_table :account_informations do
      foreign_key :account_id, :accounts, primary_key: true, type: :Bignum
      Time :created_at, null: false, default: Sequel::CURRENT_TIMESTAMP
      String :display_name, null: false
    end
  end
end
