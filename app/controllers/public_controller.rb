class PublicController < ApplicationController
  before_filter :set_user
  skip_before_filter :verify_authenticity_token

  def new_request
    request_params
    @request = @user.requests.create(request_params)
  end

  private

  def set_user
    unless User.where( email: params[:email] ).any?
      require 'securerandom'
      password = SecureRandom.hex(8)
      @user = User.create( email: params[:email], password: password, password_confirmation: password )
    else
      @user =  User.where( email: params[:email] ).first
    end
  end

  def request_params
    params.permit( :client_id, :ticket_id, :quote_id, :position, :gender, :has_color, :is_first_time, :first_name, :last_name )
  end
end
