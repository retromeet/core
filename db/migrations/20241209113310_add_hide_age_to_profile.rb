# frozen_string_literal: true

Sequel.migration do
  change do
    alter_table(:profiles) do
      add_column :hide_age, :boolean, null: false, default: false
    end
  end
end
