class AddScoreToUserKeywordHit < ActiveRecord::Migration
  def change
    add_column :user_keyword_hits, :score, :float
  end
end
