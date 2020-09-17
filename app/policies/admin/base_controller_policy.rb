# frozen_string_literal: true

class Admin::BaseControllerPolicy < ApplicationPolicy
  def index?
    @user.admin?
  end

  class Scope < Scope
    def resolve
      @user.admin? ? scope.all : scope.none
    end
  end
end
