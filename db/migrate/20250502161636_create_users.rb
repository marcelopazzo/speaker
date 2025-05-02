class CreateUsers < ActiveRecord::Migration[8.0]
  def change
    create_table :users do |t|
      t.string :email, null: false
      t.string :provider, null: false
      t.string :uid, null: false
      t.string :name, null: false
      t.string :image
      t.timestamps
    end

    add_index :users, :email, unique: true
    add_index :users, :provider
    add_index :users, :uid, unique: true
  end
end
