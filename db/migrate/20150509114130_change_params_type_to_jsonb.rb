class ChangeParamsTypeToJsonb < ActiveRecord::Migration
  def change
    change_column :user_authentications, :params, :jsonb
  end
end
