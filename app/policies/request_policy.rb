class RequestPolicy < ApplicationPolicy

  def index?
    active_salesperson?
  end

  def opt_out?
    @user
  end

  class Scope < Scope
    def resolve
      active_salesperson?  ? scope.all : scope.none
    end
  end
end
