class AddPassportInfoToUserIdentities < ActiveRecord::Migration
  def up
    add_column :user_identities, :passport_cover, :string
    add_column :user_identities, :passport_content, :string
    add_column :user_identities, :passport_with_person, :string
    add_column :user_identities, :passport_number, :string, limit: 32
    add_column :user_identities, :passport_country, :integer
  end
end
