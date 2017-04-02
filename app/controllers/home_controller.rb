class HomeController < ApplicationController
  def index
  end

  def keywords
  end

  def visuals
  end

  def connections
  end

  def keywords
    @keywords = current_user.get_top_results
    @visuals = (current_user.get_top_results || []).map{ |x| [x.user_keyword.keyword, x.score*100, x.provider, x.uri] } rescue []
  end

  def all_keywords
    @keywords = current_user.get_all_results
    @visuals = (current_user.get_all_results || []).map{ |x| [x.user_keyword.keyword, x.score, x.provider, x.uri] } rescue []
  end
end
