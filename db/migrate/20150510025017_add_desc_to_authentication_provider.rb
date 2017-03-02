class AddDescToAuthenticationProvider < ActiveRecord::Migration
  def change
    add_column :authentication_providers, :description, :string
  end
end
