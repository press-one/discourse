class ChangeRealnameToUserIdentities < ActiveRecord::Migration
  def up
    add_column :user_identities, :id_card_name, :string, limit: 32
    rename_column :user_identities, :realname, :passport_name
  end
end
