Dokno::Engine.routes.draw do
  resources :categories, except: [:show]
  resources :articles

  get '/(:cat_code)',          to: 'categories#index',     as: :article_index
  get '/up_for_review',        to: 'categories#index',     as: :up_for_review
  get 'article_panel/(:slug)', to: 'articles#panel',       as: :panel
  post 'article_preview',      to: 'articles#preview',     as: :preview
  post 'article_status',       to: 'articles#status',      as: :status
  root 'categories#index'
end
