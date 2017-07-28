class CreateUserIdentities < ActiveRecord::Migration
  def up
    create_table :user_identities, id: false do |t|
      t.references :user
      t.string :id_card_front, limit: 255
      t.string :id_card_back, limit: 255
      t.string :id_card_with_person, limit: 255
    end
    execute "ALTER TABLE user_identities ADD PRIMARY KEY (user_id)"
    execute "INSERT INTO user_identities (user_id) SELECT id FROM users"
  end

  def down
    drop_table :user_identities
  end
end
