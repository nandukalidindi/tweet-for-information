class CreateUserProfiles < ActiveRecord::Migration
  def change
    create_table :user_profiles do |t|
      t.references :user, index: true, foreign_key: true
      t.references :user_authentication, index: true, foreign_key: true
      t.string :title
      t.string :content

      t.timestamps null: false
    end
  end
end
