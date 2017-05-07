require 'sidekiq'
require 'sidekiq/web'

Rails.application.routes.draw do
  devise_for :users, controllers: { omniauth_callbacks: 'users/omniauth_callbacks' }, path_names: {sign_in: "login", sign_out: "logout"}

  devise_scope :user do
    root to: "devise/sessions#new"
  end

  get '/connections' => 'home#connections'
  get '/keywords' => 'home#keywords'
  get '/all_keywords' => 'home#all_keywords'
  get '/visuals' => 'home#visuals'

  post '/ingestion/youtube' => 'worker_processor#youtube'

  post '/ingestion/reddit' => 'worker_processor#reddit'

  post '/ingestion/bing' => 'worker_processor#bing'

  post '/ingestion/wiki' => 'worker_processor#wiki'


  mount Sidekiq::Web => '/sidekiq'
end
