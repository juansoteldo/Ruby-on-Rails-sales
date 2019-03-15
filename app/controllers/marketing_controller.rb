# frozen_string_literal: true

class MarketingController < ApplicationController
  acts_as_token_authentication_handler_for User
  before_action :authenticate_user!

  def opt_out
    @user = User.find(current_user.id)
    @user.update marketing_opt_in: false, presales_opt_in: false
    redirect_to email_preferences_url(email: @user.email)
  end

end
