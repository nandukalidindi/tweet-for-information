class AddAnalysisTypeToUserKeyword < ActiveRecord::Migration
  def change
    add_column :user_keywords, :analysis_type, :string
  end
end
