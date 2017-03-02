class UserKeyword < ActiveRecord::Base
  ANALYSIS_TYPES = {
    "keyword_extraction" => 1,
    "concept_tagging" => 2,
    "relation_extraction" => 3,
    "entity_extraction" => 4
  }
  
  belongs_to :user_snippet
  
  has_many :user_keyword_hits
  
  searchable do
    integer "user_snippet_id", :references => UserSnippet
    float "relevance"
    text "keyword"
    time "created_at"
    text "analysis_type"
  end
end
