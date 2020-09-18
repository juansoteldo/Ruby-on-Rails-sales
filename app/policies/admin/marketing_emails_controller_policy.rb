# frozen_string_literal: true

class Admin::MarketingEmailsControllerPolicy < Admin::BaseControllerPolicy
  def edit?
    @user.admin?
  end

  def show?
    @user.admin?
  end

  def update?
    @user.admin?
  end
end
