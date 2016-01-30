Rails.application.routes.draw do
  devise_for :admins
  devise_for :users

  match '*any' => 'application#options', :via => [:options]
  get 'public/redirect/:handle/:variant', to: 'public#redirect'
  post 'public/new_request'
  match 'public/get_uid', via: [:get, :post]

  namespace :admin do
    resources :products
    resources :requests

    get 'shopify/products'
    get 'shopify/variants'
    get 'shopify/customers'
    get 'shopify/customer/:customer_id', to: 'shopify#customer', as: 'shopify_customer'
    get 'shopify/customer', to: 'shopify#customer'
    match 'shopify/customer/:customer_id/orders', to: 'shopify#orders', as: 'shopify_customer_orders', via: [:get, :post]
    get 'shopify/orders'

    get 'test/quote_form' => 'test#quote_form', as: 'quote_form'
    get 'test/post_form' => 'test#post_form', as: 'post_form'

  end

  get '/admin' => 'content#admin', as: 'admin_root'
  root to: redirect('/404.html')
end
