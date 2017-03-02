class CreateUserKeywords < ActiveRecord::Migration
  def change
    create_table :user_keywords do |t|
      t.references :user_snippet, index: true, foreign_key: true
      t.float :relevance
      t.string :keyword

      t.timestamps null: false
    end
  end
end
