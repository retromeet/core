# frozen_string_literal: true

Sequel.migration do
  up do
    alter_table(:locations) do
      set_column_type :osm_id, :Bignum
    end
  end
  down do
    alter_table(:locations) do
      set_column_type :osm_id, Integer
    end
  end
end
