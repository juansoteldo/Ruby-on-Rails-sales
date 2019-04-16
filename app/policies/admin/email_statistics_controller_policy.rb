class Admin::EmailStatisticsControllerPolicy < ApplicationPolicy
  def index?
    active_salesperson? && @user.admin?
  end

  class Scope < Scope
    def resolve
      scope.all
    end
  end
end
