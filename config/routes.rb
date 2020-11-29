Dokno::Engine.routes.draw do
  resources :categories, except: [:show]
  resources :articles

  get 'article_panel/(:slug)', to: 'articles#panel',       as: :panel
  post 'article_log',          to: 'articles#article_log', as: :article_log
  post 'article_preview',      to: 'articles#preview',     as: :preview
  post 'article_status',       to: 'articles#status',      as: :status
  root 'categories#index'
end
