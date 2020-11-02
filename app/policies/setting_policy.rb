class SettingPolicy < ApplicationPolicy
  def index?
    @user.admin?
  end

  def update?
    @user.admin? || (@record == Setting.auto_quoting && active_salesperson?)
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
