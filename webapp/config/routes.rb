Rails.application.routes.draw do
  root :to => redirect('/index')
  get 'login' => 'main#login'
  get 'index' => 'main#index'
  get 'register' => 'main#register'
  post 'register' => 'main#register_post'
  post 'login' => 'main#login_post'
  post 'activation' => 'main#activation_post'

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
