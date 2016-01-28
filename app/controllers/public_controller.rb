class PublicController < ApplicationController
  skip_before_filter :verify_authenticity_token

  before_filter :set_user_by_email, only: [ :new_request ]
  before_filter :set_user_by_client_id, only: [ :get_uid ]

  def new_request
    request_params
    @request = @user.requests.create(request_params)
  end

  def get_uid
    render json: @user.id
  end

  private

  def set_user_by_client_id
    if Request.where( client_id: params[:client_id] ).any?
      user_id = Request.where( client_id: params[:client_id] ).first.user_id
      @user =  User.find(user_id)
    end
  end

  def set_user_by_email
    if User.where( email: params[:email] ).any?
      @user =  User.where( email: params[:email] ).first
    else
      password = SecureRandom.hex(8)
      @user = User.create( email: params[:email], password: password, password_confirmation: password )
    end
  end

  def request_params
    params.permit( :client_id, :ticket_id, :quote_id, :position, :gender, :has_color, :is_first_time, :first_name, :last_name )
  end
end

require 'securerandom'
