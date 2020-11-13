Rails.application.routes.draw do
  mount Dokno::Engine => "/dokno"

  root 'dummy#dummy'
end
