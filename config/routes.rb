Dokno::Engine.routes.draw do
  resources :categories
  resources :articles

  get 'article_panel/(:slug)', to: 'articles#panel',   as: :panel
  post 'article_preview',      to: 'articles#preview', as: :preview
  root 'categories#index'
end
