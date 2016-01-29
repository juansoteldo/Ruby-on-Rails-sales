Rails.application.routes.draw do
  devise_for :admins
  devise_for :users

  post 'public/new_request'
  match 'public/get_uid', via: [:get, :post]

  get 'shopify/products'

  get 'shopify/variants'
  namespace :admin do
    resources :products
    resources :requests
    get 'test/quote_form' => 'test#quote_form', as: 'quote_form'
    get 'test/post_form' => 'test#post_form', as: 'post_form'

  end

  get '/admin' => 'content#admin', as: 'admin_root'
  root to: redirect('/404.html')
end
