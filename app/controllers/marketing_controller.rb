# frozen_string_literal: true

# Controller that lets leads opt in and out of emails
class MarketingController < ApplicationController
  acts_as_token_authentication_handler_for User, fallback: :exception
  before_action :require_authentication!
  before_action :set_user, only: [:opt_out, :opt_in]

  def opt_in
    authorize @user

    @user.update! marketing_opt_in: true, presales_opt_in: true
    redirect_to edit_email_preference_url(@user, user_email: @user.email, user_token: @user.authentication_token)
  end

  def opt_out
    authorize @user

    @user.update! marketing_opt_in: false, presales_opt_in: false
    redirect_to edit_email_preference_url(@user, user_email: @user.email, user_token: @user.authentication_token)
  end

  private

  def set_user
    @user = User.find(current_user.id)
  end
end
