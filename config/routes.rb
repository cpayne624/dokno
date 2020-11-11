Dokno::Engine.routes.draw do
  get 'category/(:category_id)',            to: 'category#show', as: :category
  get 'new_category/(:parent_category_id)', to: 'category#new',  as: :new_category
  get 'edit_category/(:category_id)',       to: 'category#edit', as: :edit_category
  get 'article/(:article_id)',              to: 'article#show',  as: :article

  post 'new_category',                      to: 'category#create'
  post 'edit_category',                     to: 'category#update'

  root 'category#show'
end
