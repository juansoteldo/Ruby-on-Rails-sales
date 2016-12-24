class MarketingController < ApplicationController
  acts_as_token_authentication_handler_for User
  before_filter :authenticate_user!

  #call with https://api.customatttoodesign.ca/opt_out?user_email=alice@example.com&user_token=1G8_s7P-V-4MGojaKD7a
  def opt_out
    @user = User.find(current_user.id)
    current_user.opted_out = true
    current_user.save!
  end

end
