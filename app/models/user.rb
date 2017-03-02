class User < ActiveRecord::Base
  has_many :authentications, class_name: 'UserAuthentication', dependent: :destroy

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :omniauthable,
         :recoverable, :rememberable, :trackable, :validatable, :omniauth_providers => [:twitter, :google_oauth2]

  attr_accessor :current_password

  def self.create_from_omniauth(params)
    attributes = {
      email: params['info']['email'],
      password: Devise.friendly_token
    }

    create(attributes)
  end

  def password_required?
    super && provider.blank?
  end

  def update_with_password(params, *options)
    if encrypted_password.blank?
      update_attributes(params, *options)
    else
      super
    end
  end

  def get_top_results(provider=nil)
    keyword_hits = []

    auth_ids = authentications.all.collect(&:id)
    snippet_ids = UserSnippet.where("user_authentication_id in (?)", auth_ids).collect(&:id)
    keyword_ids = UserKeyword.where("user_snippet_id in (?)", snippet_ids).collect(&:id)

    ["twitter", "google_news"].each do |provider|
      keyword_hits_all = UserKeywordHit.where("user_keyword_id in (?) and provider=?", keyword_ids, provider).order('created_at DESC').take(500)
      keyword_hits.push UserKeywordHit.where("id in (?)", keyword_hits_all.collect(&:id)).order('score DESC').take(3)
    end

    ["wiki", "reddit", "youtube"].each do |provider|
      keyword_hits_all = UserKeywordHit.where("user_keyword_id in (?) and provider=?", keyword_ids, provider).order('created_at DESC').take(100)
      keyword_hits.push UserKeywordHit.where("id in (?)", keyword_hits_all.collect(&:id)).order('score DESC').take(2)
    end

    keyword_hits.flatten.shuffle
  end
  
  def get_all_results(provider=nil)
    keyword_hits = []

    auth_ids = authentications.all.collect(&:id)
    snippet_ids = UserSnippet.where("user_authentication_id in (?)", auth_ids).collect(&:id)
    keyword_ids = UserKeyword.where("user_snippet_id in (?)", snippet_ids).collect(&:id)

    ["twitter", "google_news", "wiki", "reddit", "youtube"].each do |provider|
      keyword_hits_all = UserKeywordHit.where("user_keyword_id in (?) and provider=?", keyword_ids, provider).order('created_at DESC')
      keyword_hits.push UserKeywordHit.where("id in (?)", keyword_hits_all.collect(&:id)).order('score DESC')
    end

    keyword_hits.flatten.shuffle
  end
end
