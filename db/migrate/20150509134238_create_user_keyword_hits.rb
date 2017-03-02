class CreateUserKeywordHits < ActiveRecord::Migration
  def change
    create_table :user_keyword_hits do |t|
      t.references :user_keyword, index: true, foreign_key: true
      t.string :provider
      t.string :uri
      t.string :content

      t.timestamps null: false
    end
  end
end
