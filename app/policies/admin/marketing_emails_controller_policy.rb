# frozen_string_literal: true

class Admin::MarketingEmailsControllerPolicy < Admin::BaseControllerPolicy
  def edit?
    @user.admin?
  end
end
