require "sidekiq/web"

Rails.application.routes.draw do
  resources :email_preferences, only: [:edit, :update, :index]
  devise_for :salespeople
  devise_for :admins
  devise_for :users

  match "*any" => "application#options", :via => [:options]

  get "/public/redirect/:handle/:variant", to: "public#redirect", as: :cart_redirect, defaults: { format: "html" }
  post "/public/new_request", as: :new_request
  match "/public/get_uid", via: [:get, :post], as: :get_uid, defaults: { format: "json" }
  get "/public/get_links", as: :get_links, defaults: { format: "json" }
  get "/public/set_link", as: :set_link, defaults: { format: "json" }
  get "/public/save_email", as: :save_email, defaults: { format: "json" }
  get "/marketing/opt_out", to: "marketing#opt_out", as: :marketing_opt_out
  get "/marketing/opt_in", to: "marketing#opt_in", as: :marketing_opt_in
  get '/public/unsubscribed', to: 'public#unsubscribed', as: :unsubscribed
  match "public/thanks", via: [:get, :post], to: "public#deposit_redirect", as: :deposit_redirect

  post '/cm/update-subscriptions', to: 'cm#update_subscriptions'

  get "/events/create", to: "events#create"

  resources :events, only: [:show]

  namespace :api do
    resources :requests, only: [:index, :show, :update]
    resources :request_images, only: [:show]
    resources :users, only: [:index, :show]
    patch "/users", to: "users#update"
  end

  namespace :webhooks do
    post "orders_create" => :orders_create
    post "requests_create" => :requests_create
    post "calendly" => :events_create
    post "newsletter" => :newsletter_signup
  end

  match "public/get_ids", via: [:get, :post]

  namespace :admin do
    get 'shopify/add_order' => 'shopify#index'
    post 'shopify/add_order' => 'shopify#add_order'

    resources :users, only: [:index]
    resources :products
    resources :requests do
      member do
        match :opt_out, via: [:all], as: :opt_out
        match :opt_in, via: [:all], as: :opt_in
        match :send_confirmation, via: [:all], as: :send_confirmation
      end
    end

    resources :settings, only: [:update]

    resources :events, only: [:index]

    resources :salespeople do
      collection do
        get :how_to
      end
    end

    resources :marketing_emails, only: [:show, :update, :edit]

    resources :webhooks, only: [:index, :destroy] do
      member do
        get "perform"
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

    get '/campaign_monitor' => 'campaign_monitor#index'
    put '/campaign_monitor', to: 'campaign_monitor#update'

    get '/shopify_auth' => 'shopify_auth#index'
    get '/shopify_auth/new' => 'shopify_auth#login', as: 'shopify_auth_login'
    get '/shopify_auth/callback' => 'shopify_auth#callback'

    authenticated :salesperson, ->(user) { user&.admin? } do
      mount Sidekiq::Web => "sidekiq"
    end
  end

  get "/admin" => "content#admin", as: "admin_root"

  root to: redirect("/404.html")
end
