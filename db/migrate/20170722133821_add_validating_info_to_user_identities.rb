class AddValidatingInfoToUserIdentities < ActiveRecord::Migration
  def up
    add_column :user_identities, :validating_status, :integer, null: false, default: 0
    add_column :user_identities, :id_card_number, :string, limit: 32
    add_column :user_identities, :realname, :string, limit: 32
    add_column :user_identities, :confidence, :integer, null: false, default: 0
  end
end
