Dokno::Engine.routes.draw do
  # Categories
  get 'category/(:category_id)',            to: 'category#show', as: :category
  get 'new_category/(:parent_category_id)', to: 'category#new',  as: :new_category
  get 'edit_category/(:category_id)',       to: 'category#edit', as: :edit_category

  post 'new_category',                      to: 'category#create'
  post 'edit_category',                     to: 'category#update'

  # Articles
  get 'article/(:article_id)',              to: 'article#show',  as: :article
  get 'new_article/(:category_id)',         to: 'article#new',   as: :new_article

  post 'new_article',                       to: 'article#create'

  root 'category#show'
end
