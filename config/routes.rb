Dokno::Engine.routes.draw do
  resources :categories
  resources :articles

  get 'article_panel/(:slug)', to: 'article#panel', as: :panel

  # # Categories
  # get 'category/(:cat_id)',                 to: 'category#show', as: :category
  # get 'new_category/(:parent_category_id)', to: 'category#new',  as: :new_category
  # get 'edit_category/(:cat_id)',            to: 'category#edit', as: :edit_category

  # post 'new_category',                      to: 'category#create'
  # post 'edit_category',                     to: 'category#update'

  # # Articles
  # get 'article/(:article_id)',              to: 'article#show',  as: :article
  # get 'edit_article/(:article_id)',         to: 'article#edit',  as: :edit_article
  # get 'article_panel/(:slug)',              to: 'article#panel', as: :panel
  # get 'new_article/(:category_id)',         to: 'article#new',   as: :new_article

  # post 'new_article',                       to: 'article#create'
  # post 'edit_article',                      to: 'article#update'

  root 'categories#index'
end
