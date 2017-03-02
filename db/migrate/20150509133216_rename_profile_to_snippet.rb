class RenameProfileToSnippet < ActiveRecord::Migration
  def change
    rename_table :user_profiles, :user_snippets
  end
end
