class ChangeParamsTypeToJson < ActiveRecord::Migration
  def change
    change_column :user_authentications, :params, 'JSON USING to_json(params)'
  end
end
