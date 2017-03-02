class AddLastPositionToUserAuthentication < ActiveRecord::Migration
  def change
    add_column :user_authentications, :last_position, :string
  end
end
