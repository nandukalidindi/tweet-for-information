class ChangeParamsTypeToJsonb < ActiveRecord::Migration
  def change
    change_column :user_authentications, :params, 'jsonb USING CAST(params AS jsonb)'
  end
end
