class UserPolicy < ApplicationPolicy

  def index?
    @user&.admin?
  end

  def opt_out?
    true
  end

  def update?
    true
  end

  class Scope < Scope
    def resolve
      if @user.admin?
        scope.all
      else
        scope.none
      end
    end
  end
end
