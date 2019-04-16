class EventPolicy < ApplicationPolicy
  def create?
    true
  end

  def show?
    true
  end

  def index?
    active_salesperson?
  end

  class Scope < Scope
    def resolve
      scope.all
    end
  end
end
