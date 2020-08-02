class UserPolicy < ApplicationPolicy
  def index?
    @user&.admin?
  end

  def opt_out?
    active_salesperson? || @user == @record
  end

  def opt_in?
    active_salesperson? || @user == @record
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
