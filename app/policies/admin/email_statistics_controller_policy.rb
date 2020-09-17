# frozen_string_literal: true

class Admin::EmailStatisticsControllerPolicy < Admin::BaseControllerPolicy
  def index?
    active_salesperson? || @user.admin?
  end

  class Scope < Scope
    def resolve
      scope.all
    end
  end
end
