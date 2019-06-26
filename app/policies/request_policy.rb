class RequestPolicy < ApplicationPolicy

  def index?
    active_salesperson?
  end

  def opt_out?
    active_salesperson? || @user == @record.user
  end

  def opt_in?
    active_salesperson? || @user == @record.user
  end

  class Scope < Scope
    def resolve
      active_salesperson? ? scope.all : scope.where(user: @user)
    end
  end
end
