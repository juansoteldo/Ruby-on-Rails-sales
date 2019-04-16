# frozen_string_literal: true

class MarketingController < ApplicationController
  acts_as_token_authentication_handler_for User
  before_action :authenticate_user!
  before_action :load_user, only: [:opt_out]

  def opt_out
    authorize @user
    @user.update marketing_opt_in: false, presales_opt_in: false
    redirect_to email_preferences_url(email: @user.email)
  end

  private

  def load_user
    @user = User.find(current_user.id)
  end
end
