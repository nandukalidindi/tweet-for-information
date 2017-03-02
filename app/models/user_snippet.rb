class UserSnippet < ActiveRecord::Base
  belongs_to :user_authentication
  has_many :user_keywords
  
  searchable do
    text :title, :content

    integer :user_authentication_id
  end
end
