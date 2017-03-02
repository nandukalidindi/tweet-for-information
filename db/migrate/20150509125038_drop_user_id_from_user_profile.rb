class DropUserIdFromUserProfile < ActiveRecord::Migration
  def change
    remove_column :user_profiles, :user_id
  end
end
