Rails.application.routes.draw do

  get "email_preferences", to: "email_preferences#edit"
  resources :email_preferences, only: [:update]
  devise_for :salespeople
  devise_for :admins
  devise_for :users

  match "*any" => "application#options", :via => [:options]

  get "/public/redirect/:handle/:variant", to: "public#redirect", as: :cart_redirect
  post "/public/new_request", as: :new_request
  match "/public/get_uid", via: [:get, :post], as: :get_uid
  get "/public/get_links", as: :get_links
  get "/public/set_link", as: :set_link
  get "/public/save_email", as: :save_email
  get "public/opt_out/:id", to: "marketing#opt_out", as: :opt_out
  match "public/thanks", via: [:get, :post], to: "public#deposit_redirect", as: :deposit_redirect

  get "/events/create", to: "events#create"

  resources :events, only: [:show]

  namespace :api do
    resources :requests, only: [:index, :show, :update]
    resources :request_images, only: [:show]
    resources :users, only: [:index, :show]
  end

  namespace :webhooks do
    post "orders_create" => :orders_create
    post "requests_create" => :requests_create
    post "calendly" => :calendly
  end

  match "public/get_ids", via: [:get, :post]

  namespace :admin do
    resources :users, only: [:index]
    resources :products
    resources :requests do
      member do
        match :opt_out, via: [:all], as: :opt_out
        match :opt_in, via: [:all], as: :opt_in
      end
    end

    resources :events, only: [:index]

    resources :salespeople do
      collection do
        get :how_to
      end
    end

    get "/email_statistics" => "email_statistics#index"

    get "shopify/products"
    get "shopify/variants"
    get "shopify/customers"
    get "shopify/customer/:customer_id", to: "shopify#customer", as: "shopify_customer"
    get "shopify/customer", to: "shopify#customer"
    match "shopify/customer/:customer_id/orders", to: "shopify#orders", as: "shopify_customer_orders", via: [:get, :post]
    get "shopify/orders"

    get "test/quote_form" => "test#quote_form", as: "quote_form"
    get "test/post_form" => "test#post_form", as: "post_form"
    get "test/cart" => "test#cart", as: "cart"

    mount DelayedJobWeb, at: "/delayed_job"
  end

  get "/admin" => "content#admin", as: "admin_root"


  root to: redirect("/404.html")
end
