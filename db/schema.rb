# **Autogenerated file! Do not modify by hand!**
# Current migration: 20240919102154_account_information.rb

Sequel.migration do
  change do
    create_table(:account_statuses, :ignore_index_errors=>true) do
      Integer :id, :null=>false
      String :name, :text=>true, :null=>false
      
      primary_key [:id]
      
      index [:name], :name=>:account_statuses_name_key, :unique=>true
    end
    
    create_table(:schema_info_password) do
      String :filename, :text=>true, :null=>false
      
      primary_key [:filename]
    end
    
    create_table(:schema_migrations) do
      String :filename, :text=>true, :null=>false
      
      primary_key [:filename]
    end
    
    create_table(:accounts) do
      primary_key :id, :type=>:Bignum
      foreign_key :status_id, :account_statuses, :default=>1, :null=>false, :key=>[:id]
      String :email, :null=>false
    end
    
    create_table(:account_active_session_keys) do
      foreign_key :account_id, :accounts, :type=>:Bignum, :null=>false, :key=>[:id]
      String :session_id, :text=>true, :null=>false
      DateTime :created_at, :default=>Sequel::CURRENT_TIMESTAMP, :null=>false
      DateTime :last_use, :default=>Sequel::CURRENT_TIMESTAMP, :null=>false
      
      primary_key [:account_id, :session_id]
    end
    
    create_table(:account_activity_times) do
      foreign_key :id, :accounts, :type=>:Bignum, :null=>false, :key=>[:id]
      DateTime :last_activity_at, :null=>false
      DateTime :last_login_at, :null=>false
      DateTime :expired_at
      
      primary_key [:id]
    end
    
    create_table(:account_authentication_audit_logs, :ignore_index_errors=>true) do
      primary_key :id, :type=>:Bignum
      foreign_key :account_id, :accounts, :type=>:Bignum, :null=>false, :key=>[:id]
      DateTime :at, :default=>Sequel::CURRENT_TIMESTAMP, :null=>false
      String :message, :text=>true, :null=>false
      String :metadata
      
      index [:account_id, :at], :name=>:audit_account_at_idx
      index [:at], :name=>:audit_at_idx
    end
    
    create_table(:account_email_auth_keys) do
      foreign_key :id, :accounts, :type=>:Bignum, :null=>false, :key=>[:id]
      String :key, :text=>true, :null=>false
      DateTime :deadline, :default=>Sequel::CURRENT_TIMESTAMP, :null=>false
      DateTime :email_last_sent, :default=>Sequel::CURRENT_TIMESTAMP, :null=>false
      
      primary_key [:id]
    end
    
    create_table(:account_informations) do
      foreign_key :account_id, :accounts, :type=>:Bignum, :null=>false, :key=>[:id]
      DateTime :created_at, :default=>Sequel::CURRENT_TIMESTAMP, :null=>false
      String :display_name, :text=>true, :null=>false
      
      primary_key [:account_id]
    end
    
    create_table(:account_jwt_refresh_keys, :ignore_index_errors=>true) do
      primary_key :id, :type=>:Bignum
      foreign_key :account_id, :accounts, :type=>:Bignum, :null=>false, :key=>[:id]
      String :key, :text=>true, :null=>false
      DateTime :deadline, :default=>Sequel::CURRENT_TIMESTAMP, :null=>false
      
      index [:account_id], :name=>:account_jwt_rk_account_id_idx
    end
    
    create_table(:account_lockouts) do
      foreign_key :id, :accounts, :type=>:Bignum, :null=>false, :key=>[:id]
      String :key, :text=>true, :null=>false
      DateTime :deadline, :default=>Sequel::CURRENT_TIMESTAMP, :null=>false
      DateTime :email_last_sent
      
      primary_key [:id]
    end
    
    create_table(:account_login_change_keys) do
      foreign_key :id, :accounts, :type=>:Bignum, :null=>false, :key=>[:id]
      String :key, :text=>true, :null=>false
      String :login, :text=>true, :null=>false
      DateTime :deadline, :default=>Sequel::CURRENT_TIMESTAMP, :null=>false
      
      primary_key [:id]
    end
    
    create_table(:account_login_failures) do
      foreign_key :id, :accounts, :type=>:Bignum, :null=>false, :key=>[:id]
      Integer :number, :default=>1, :null=>false
      
      primary_key [:id]
    end
    
    create_table(:account_otp_keys) do
      foreign_key :id, :accounts, :type=>:Bignum, :null=>false, :key=>[:id]
      String :key, :text=>true, :null=>false
      Integer :num_failures, :default=>0, :null=>false
      DateTime :last_use, :default=>Sequel::CURRENT_TIMESTAMP, :null=>false
      
      primary_key [:id]
    end
    
    create_table(:account_password_change_times) do
      foreign_key :id, :accounts, :type=>:Bignum, :null=>false, :key=>[:id]
      DateTime :changed_at, :default=>Sequel::CURRENT_TIMESTAMP, :null=>false
      
      primary_key [:id]
    end
    
    create_table(:account_password_hashes) do
      foreign_key :id, :accounts, :type=>:Bignum, :null=>false, :key=>[:id]
      String :password_hash, :text=>true, :null=>false
      
      primary_key [:id]
    end
    
    create_table(:account_password_reset_keys) do
      foreign_key :id, :accounts, :type=>:Bignum, :null=>false, :key=>[:id]
      String :key, :text=>true, :null=>false
      DateTime :deadline, :default=>Sequel::CURRENT_TIMESTAMP, :null=>false
      DateTime :email_last_sent, :default=>Sequel::CURRENT_TIMESTAMP, :null=>false
      
      primary_key [:id]
    end
    
    create_table(:account_previous_password_hashes) do
      primary_key :id, :type=>:Bignum
      foreign_key :account_id, :accounts, :type=>:Bignum, :key=>[:id]
      String :password_hash, :text=>true, :null=>false
    end
    
    create_table(:account_recovery_codes) do
      foreign_key :id, :accounts, :type=>:Bignum, :null=>false, :key=>[:id]
      String :code, :text=>true, :null=>false
      
      primary_key [:id, :code]
    end
    
    create_table(:account_remember_keys) do
      foreign_key :id, :accounts, :type=>:Bignum, :null=>false, :key=>[:id]
      String :key, :text=>true, :null=>false
      DateTime :deadline, :default=>Sequel::CURRENT_TIMESTAMP, :null=>false
      
      primary_key [:id]
    end
    
    create_table(:account_session_keys) do
      foreign_key :id, :accounts, :type=>:Bignum, :null=>false, :key=>[:id]
      String :key, :text=>true, :null=>false
      
      primary_key [:id]
    end
    
    create_table(:account_sms_codes) do
      foreign_key :id, :accounts, :type=>:Bignum, :null=>false, :key=>[:id]
      String :phone_number, :text=>true, :null=>false
      Integer :num_failures
      String :code, :text=>true
      DateTime :code_issued_at, :default=>Sequel::CURRENT_TIMESTAMP, :null=>false
      
      primary_key [:id]
    end
    
    create_table(:account_verification_keys) do
      foreign_key :id, :accounts, :type=>:Bignum, :null=>false, :key=>[:id]
      String :key, :text=>true, :null=>false
      DateTime :requested_at, :default=>Sequel::CURRENT_TIMESTAMP, :null=>false
      DateTime :email_last_sent, :default=>Sequel::CURRENT_TIMESTAMP, :null=>false
      
      primary_key [:id]
    end
    
    create_table(:account_webauthn_keys) do
      foreign_key :account_id, :accounts, :type=>:Bignum, :null=>false, :key=>[:id]
      String :webauthn_id, :text=>true, :null=>false
      String :public_key, :text=>true, :null=>false
      Integer :sign_count, :null=>false
      DateTime :last_use, :default=>Sequel::CURRENT_TIMESTAMP, :null=>false
      
      primary_key [:account_id, :webauthn_id]
    end
    
    create_table(:account_webauthn_user_ids) do
      foreign_key :id, :accounts, :type=>:Bignum, :null=>false, :key=>[:id]
      String :webauthn_id, :text=>true, :null=>false
      
      primary_key [:id]
    end
  end
end
