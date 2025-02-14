# frozen_string_literal: true

Sequel.migration do
  up do
    alter_table(:profiles) do
      add_column :pronouns, :text
    end
  end
  down do
    alter_table(:profiles) do
      drop_column :pronouns
    end
  end
end
