Rails.application.routes.draw do
  devise_for :salespeople
  devise_for :admins
  devise_for :users


  match '*any' => 'application#options', :via => [:options]
  get '/.well-known/acme-challenge/:challenge', to: 'public#letsencrypt'
  get 'public/redirect/:handle/:variant', to: 'public#redirect'
  post 'public/new_request'
  match 'public/get_uid', via: [:get, :post]
  match 'public/get_links', via: [:get]
  namespace :webhooks do
    post 'orders_create' => :orders_create
  end

  match 'public/get_ids', via: [:get, :post]
  get 'public/widget(.js)', to: 'public#widget'

  namespace :admin do
    resources :products
    resources :requests
    resources :salespeople

    get 'shopify/products'
    get 'shopify/variants'
    get 'shopify/customers'
    get 'shopify/customer/:customer_id', to: 'shopify#customer', as: 'shopify_customer'
    get 'shopify/customer', to: 'shopify#customer'
    match 'shopify/customer/:customer_id/orders', to: 'shopify#orders', as: 'shopify_customer_orders', via: [:get, :post]
    get 'shopify/orders'

    get 'test/quote_form' => 'test#quote_form', as: 'quote_form'
    get 'test/post_form' => 'test#post_form', as: 'post_form'
    get 'test/cart' => 'test#cart', as: 'cart'

  end

  get '/admin' => 'content#admin', as: 'admin_root'
  root to: redirect('/404.html')
end
