class UserKeywordHit < ActiveRecord::Base
  belongs_to :user_keyword
  delegate :analysis_type, :relevance, to: :user_keyword

  scope :top_10, ->{ where() }
end
