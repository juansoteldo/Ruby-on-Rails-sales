# frozen_string_literal: true

class MarketingController < ApplicationController
  acts_as_token_authentication_handler_for User, fallback: :none
  before_action :authenticate_user!
  before_action :set_user, only: [:opt_out, :opt_in]

  def opt_in
    authorize @user

    @user.update! marketing_opt_in: true, presales_opt_in: true
    redirect_to edit_email_preference_url(@user)
  end

  def opt_out
    authorize @user

    @user.update! marketing_opt_in: false, presales_opt_in: false
    redirect_to edit_email_preference_url(@user)
  end

  private

  def set_user
    head 404 && return unless current_user
    @user = User.find(current_user.id)
  end
end
