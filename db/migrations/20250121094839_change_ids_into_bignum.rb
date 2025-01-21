# frozen_string_literal: true

Sequel.migration do
  up do
    alter_table(:profile_blocks) do
      set_column_type :id, :Bignum
    end

    alter_table(:messages) do
      set_column_type :id, :Bignum
    end
  end
  down do
    alter_table(:profile_blocks) do
      set_column_type :id, Integer
    end

    alter_table(:messages) do
      set_column_type :id, Integer
    end
  end
end
