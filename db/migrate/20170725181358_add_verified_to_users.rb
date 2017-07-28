class AddVerifiedToUsers < ActiveRecord::Migration
  def up
    add_column :users, :verified, :boolean, null: false, default: false
  end
end
