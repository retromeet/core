# frozen_string_literal: true

Sequel.migration do
  change do
    alter_table(:profiles) do
      add_column :picture, :jsonb
    end
  end
end
