class WebhookPolicy < ApplicationPolicy
  def index?
    @user&.admin?
  end

  def perform?
    @user&.admin?
  end

  class Scope < Scope
    def resolve
      @user&.admin? ? scope.all : scope.none
    end
  end
end