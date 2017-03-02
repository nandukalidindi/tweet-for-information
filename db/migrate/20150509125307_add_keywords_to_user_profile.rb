class AddKeywordsToUserProfile < ActiveRecord::Migration
  def change
    add_column :user_profiles, :keywords, :jsonb
  end
end
