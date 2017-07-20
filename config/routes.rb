Rails.application.routes.draw do
  devise_for :salespeople
  devise_for :admins
  devise_for :users

  match '*any' => 'application#options', :via => [:options]
  get 'public/redirect/:handle/:variant', to: 'public#redirect', as: :cart_redirect
  post 'public/new_request'
  match 'public/get_uid', via: [:get, :post]
  match 'public/get_links', via: [:get]
  match 'public/set_link', via: [:get]
  match 'public/save_email', via: [:get]
  get 'public/opt_out/:id', to: 'marketing#opt_out', as: :opt_out

  namespace :api do
    resources :requests, only: [:index, :show]
    resources :request_images, only: [:show]
  end

  namespace :webhooks do
    post 'orders_create' => :orders_create
    post 'requests_create' => :requests_create
  end

  match 'public/get_ids', via: [:get, :post]

  namespace :admin do
    resources :products
    resources :requests do
      member do
        match :opt_out, via: [:all], as: :opt_out
        match :opt_in, via: [:all], as: :opt_in
      end
    end

    resources :salespeople do
      collection do
        get :how_to
      end
    end

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

    mount DelayedJobWeb, at: "/delayed_job", :constraints => AdminConstraint.new
  end

  get '/admin' => 'content#admin', as: 'admin_root'
  root to: redirect('/404.html')
end
