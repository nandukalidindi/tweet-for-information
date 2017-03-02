class AddEnabledToAuthenticationProvider < ActiveRecord::Migration
  def change
    add_column :authentication_providers, :enabled, :boolean
  end
end
