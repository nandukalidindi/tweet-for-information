class AddUsernameAndMobileToUsers < ActiveRecord::Migration
  def change
    add_column :users, :username, :string
    add_column :users, :mobile, :string
  end
end
