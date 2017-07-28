class AddErrorMessageToUserIdentities < ActiveRecord::Migration
  def up
    add_column :user_identities, :error_message, :string
  end
end
