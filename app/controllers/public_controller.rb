class PublicController < ApplicationController
  skip_before_filter :verify_authenticity_token

  before_filter :validate_parameters, only: [:new_request]
  before_filter :set_user_by_email, only: [ :new_request ]
  before_filter :set_user_by_client_id, only: [ :get_uid ]

  def redirect
    @variant = params[:variant]
    @handle = params[:handle]

    if params[:requestId] != nil && Request.where(id: params[:requestId] ).any?
      @request = Request.find(params[:requestId])
    end
    if not @request and ( params[:_ga] and Request.where(_ga: params[:_ga]).any? )
      @request = Request.find_by__ga(params[:_ga])
    end

    if @request
      @request.update_columns( variant: @variant, handle: @handle, last_visited_at: Time.now )
      @url ="http://shop.customtattoodesign.ca/products/#{@handle}?variant=#{@variant}&uid=#{@request.user_id}&cid=#{@request.client_id}"
    else
      @url = "http://shop.customtattoodesign.ca/products/#{@handle}?variant=#{@variant}&utm_campaign=unlisted&utm_source=crm&utm_medium=email"
    end
  end

  def new_request
    request_params
    if Request.recent.where(user_id: @user.id, position: params[:position]).any?
      Request.recent.where(user_id: @user.id, position: params[:position]).delete_all
    end
    @request = @user.requests.create(request_params)
  end

  def get_uid
    render json: @user.id
  end

  def letsencrypt
    render text: 'eUpvbra_e3D3xwFDfnZvsVsFQPxvhZmZr2vmf6C0DmA.12TMAWfXdIvgt6ql1dtZLJJfdL0YOluvbSDX4-5jhd8'

  end

  private

    def set_user_by_client_id
      if Request.where( client_id: params[:client_id] ).any?
        user_id = Request.find_by_client_id( params[:client_id] ).user_id
        @user =  User.find(user_id)
      else
        render json: false
      end
    end

    def set_user_by_email
      if User.where( email: params[:email] ).any?
        @user =  User.find_by_email( params[:email] )
      else
        password = SecureRandom.hex(8)
        @user = User.create( email: params[:email], password: password, password_confirmation: password )
      end
    end

    def validate_parameters
       [:position, :gender, :first_name, :last_name, :client_id ].each do |sym|
          render( json: false ) if params[sym] == '' or params[sym] == false
        end
    end

    def request_params
      params.permit( :client_id, :ticket_id, :quote_id, :position, :gender,
                     :has_color, :is_first_time, :first_name, :last_name, :linker_param, :_ga )
    end

end

require 'securerandom'
