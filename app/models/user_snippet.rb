class UserSnippet < ActiveRecord::Base
  belongs_to :user_authentication
  has_many :user_keywords
end
