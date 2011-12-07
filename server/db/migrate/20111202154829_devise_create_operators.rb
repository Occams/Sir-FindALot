class DeviseCreateOperators < ActiveRecord::Migration
  def change
    create_table(:operators) do |t|
      t.database_authenticatable :null => false
      t.recoverable
      t.rememberable
      t.trackable

      # t.encryptable
      t.confirmable
      t.lockable :lock_strategy => :failed_attempts, :unlock_strategy => :both
      t.token_authenticatable
      
      # User defined columns
      t.string :name
      
      t.timestamps
    end

    add_index :operators, :email,                :unique => true
    add_index :operators, :reset_password_token, :unique => true
    add_index :operators, :confirmation_token,   :unique => true
    add_index :operators, :unlock_token,         :unique => true
    add_index :operators, :authentication_token, :unique => true
  end

end
