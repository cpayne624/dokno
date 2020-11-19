Rails.application.routes.draw do
  mount Dokno::Engine => "/help"

  root 'dummy#dummy'
end
