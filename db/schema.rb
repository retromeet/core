# **Autogenerated file! Do not modify by hand!**
# Current migration: 20241107100228_add_location_tables_and_extension.rb

Sequel.migration do
  change do
    create_table(:account_statuses) do
      column :id, "integer", null: false
      column :name, "text", null: false

      primary_key %i[id]

      index %i[name], name: :account_statuses_name_key, unique: true
    end

    create_table(:locations) do
      primary_key :id, type: :Bignum
      column :geom, "geometry(Point,4326)", null: false
      column :display_name, "jsonb", null: false
      column :osm_id, "integer", null: false
      column :country_code, "countries_iso_3166_1_alpha2", null: false

      index %i[osm_id], name: :locations_osm_id_key, unique: true
    end

    create_table(:schema_info_password) do
      column :filename, "text", null: false

      primary_key %i[filename]
    end

    create_table(:schema_migrations) do
      column :filename, "text", null: false

      primary_key %i[filename]
    end

    create_table(:spatial_ref_sys) do
      column :srid, "integer", null: false
      column :auth_name, "character varying(256)"
      column :auth_srid, "integer"
      column :srtext, "character varying(2048)"
      column :proj4text, "character varying(2048)"

      primary_key %i[srid]
    end

    create_table(:accounts) do
      primary_key :id, type: :Bignum
      foreign_key :status_id, :account_statuses, default: 1, null: false, key: %i[id]
      column :email, "citext", null: false
    end

    create_table(:account_active_session_keys) do
      foreign_key :account_id, :accounts, type: "bigint", null: false, key: %i[id]
      column :session_id, "text", null: false
      column :created_at, "timestamp without time zone", default: Sequel::CURRENT_TIMESTAMP, null: false
      column :last_use, "timestamp without time zone", default: Sequel::CURRENT_TIMESTAMP, null: false

      primary_key %i[account_id session_id]
    end

    create_table(:account_activity_times) do
      foreign_key :id, :accounts, type: "bigint", null: false, key: %i[id]
      column :last_activity_at, "timestamp without time zone", null: false
      column :last_login_at, "timestamp without time zone", null: false
      column :expired_at, "timestamp without time zone"

      primary_key %i[id]
    end

    create_table(:account_authentication_audit_logs) do
      primary_key :id, type: :Bignum
      foreign_key :account_id, :accounts, type: "bigint", null: false, key: %i[id]
      column :at, "timestamp without time zone", default: Sequel::CURRENT_TIMESTAMP, null: false
      column :message, "text", null: false
      column :metadata, "jsonb"

      index %i[account_id at], name: :audit_account_at_idx
      index %i[at], name: :audit_at_idx
    end

    create_table(:account_email_auth_keys) do
      foreign_key :id, :accounts, type: "bigint", null: false, key: %i[id]
      column :key, "text", null: false
      column :deadline, "timestamp without time zone", default: Sequel::CURRENT_TIMESTAMP, null: false
      column :email_last_sent, "timestamp without time zone", default: Sequel::CURRENT_TIMESTAMP, null: false

      primary_key %i[id]
    end

    create_table(:account_informations) do
      foreign_key :account_id, :accounts, type: "bigint", null: false, key: %i[id]
      column :created_at, "timestamp without time zone", default: Sequel::CURRENT_TIMESTAMP, null: false
      column :display_name, "text", null: false
      column :about_me, "text"
      column :birth_date, "date"
      column :genders, "genders[]"
      column :orientations, "orientations[]"
      column :languages, "languages[]"
      column :relationship_type, "relationship_type"
      column :relationship_status, "relationship_status"
      column :tobacco, "frequency"
      column :marijuana, "frequency"
      column :alcohol, "frequency"
      column :other_recreational_drugs, "frequency"
      column :pets, "haves_or_have_nots"
      column :wants_pets, "wants"
      column :kids, "haves_or_have_nots"
      column :wants_kids, "wants"
      column :religion, "religions"
      column :religion_importance, "importance"
      foreign_key :location_id, :locations, type: "bigint", key: %i[id]

      primary_key %i[account_id]
    end

    create_table(:account_jwt_refresh_keys) do
      primary_key :id, type: :Bignum
      foreign_key :account_id, :accounts, type: "bigint", null: false, key: %i[id]
      column :key, "text", null: false
      column :deadline, "timestamp without time zone", default: Sequel::CURRENT_TIMESTAMP, null: false

      index %i[account_id], name: :account_jwt_rk_account_id_idx
    end

    create_table(:account_lockouts) do
      foreign_key :id, :accounts, type: "bigint", null: false, key: %i[id]
      column :key, "text", null: false
      column :deadline, "timestamp without time zone", default: Sequel::CURRENT_TIMESTAMP, null: false
      column :email_last_sent, "timestamp without time zone"

      primary_key %i[id]
    end

    create_table(:account_login_change_keys) do
      foreign_key :id, :accounts, type: "bigint", null: false, key: %i[id]
      column :key, "text", null: false
      column :login, "text", null: false
      column :deadline, "timestamp without time zone", default: Sequel::CURRENT_TIMESTAMP, null: false

      primary_key %i[id]
    end

    create_table(:account_login_failures) do
      foreign_key :id, :accounts, type: "bigint", null: false, key: %i[id]
      column :number, "integer", default: 1, null: false

      primary_key %i[id]
    end

    create_table(:account_otp_keys) do
      foreign_key :id, :accounts, type: "bigint", null: false, key: %i[id]
      column :key, "text", null: false
      column :num_failures, "integer", default: 0, null: false
      column :last_use, "timestamp without time zone", default: Sequel::CURRENT_TIMESTAMP, null: false

      primary_key %i[id]
    end

    create_table(:account_password_change_times) do
      foreign_key :id, :accounts, type: "bigint", null: false, key: %i[id]
      column :changed_at, "timestamp without time zone", default: Sequel::CURRENT_TIMESTAMP, null: false

      primary_key %i[id]
    end

    create_table(:account_password_hashes) do
      foreign_key :id, :accounts, type: "bigint", null: false, key: %i[id]
      column :password_hash, "text", null: false

      primary_key %i[id]
    end

    create_table(:account_password_reset_keys) do
      foreign_key :id, :accounts, type: "bigint", null: false, key: %i[id]
      column :key, "text", null: false
      column :deadline, "timestamp without time zone", default: Sequel::CURRENT_TIMESTAMP, null: false
      column :email_last_sent, "timestamp without time zone", default: Sequel::CURRENT_TIMESTAMP, null: false

      primary_key %i[id]
    end

    create_table(:account_previous_password_hashes) do
      primary_key :id, type: :Bignum
      foreign_key :account_id, :accounts, type: "bigint", key: %i[id]
      column :password_hash, "text", null: false
    end

    create_table(:account_recovery_codes) do
      foreign_key :id, :accounts, type: "bigint", null: false, key: %i[id]
      column :code, "text", null: false

      primary_key %i[id code]
    end

    create_table(:account_remember_keys) do
      foreign_key :id, :accounts, type: "bigint", null: false, key: %i[id]
      column :key, "text", null: false
      column :deadline, "timestamp without time zone", default: Sequel::CURRENT_TIMESTAMP, null: false

      primary_key %i[id]
    end

    create_table(:account_session_keys) do
      foreign_key :id, :accounts, type: "bigint", null: false, key: %i[id]
      column :key, "text", null: false

      primary_key %i[id]
    end

    create_table(:account_sms_codes) do
      foreign_key :id, :accounts, type: "bigint", null: false, key: %i[id]
      column :phone_number, "text", null: false
      column :num_failures, "integer"
      column :code, "text"
      column :code_issued_at, "timestamp without time zone", default: Sequel::CURRENT_TIMESTAMP, null: false

      primary_key %i[id]
    end

    create_table(:account_verification_keys) do
      foreign_key :id, :accounts, type: "bigint", null: false, key: %i[id]
      column :key, "text", null: false
      column :requested_at, "timestamp without time zone", default: Sequel::CURRENT_TIMESTAMP, null: false
      column :email_last_sent, "timestamp without time zone", default: Sequel::CURRENT_TIMESTAMP, null: false

      primary_key %i[id]
    end

    create_table(:account_webauthn_keys) do
      foreign_key :account_id, :accounts, type: "bigint", null: false, key: %i[id]
      column :webauthn_id, "text", null: false
      column :public_key, "text", null: false
      column :sign_count, "integer", null: false
      column :last_use, "timestamp without time zone", default: Sequel::CURRENT_TIMESTAMP, null: false

      primary_key %i[account_id webauthn_id]
    end

    create_table(:account_webauthn_user_ids) do
      foreign_key :id, :accounts, type: "bigint", null: false, key: %i[id]
      column :webauthn_id, "text", null: false

      primary_key %i[id]
    end
  end
end
