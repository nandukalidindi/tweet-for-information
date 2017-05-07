class UserKeyword < ActiveRecord::Base
  ANALYSIS_TYPES = {
    "keyword_extraction" => 1,
    "concept_tagging" => 2,
    "relation_extraction" => 3,
    "entity_extraction" => 4
  }

  belongs_to :user_snippet

  has_many :user_keyword_hits
end
