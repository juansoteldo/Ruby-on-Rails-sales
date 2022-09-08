# frozen_string_literal: true

class Admin::CampaignMonitorControllerPolicy < Admin::BaseControllerPolicy
  def index?
    @user.admin?
  end
  
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
