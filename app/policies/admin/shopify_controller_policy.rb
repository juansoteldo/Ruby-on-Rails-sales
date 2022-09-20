# frozen_string_literal: true

class Admin::ShopifyControllerPolicy < Admin::BaseControllerPolicy
  def index?
    active_salesperson?
  end

  def edit?
    active_salesperson?
  end

  def show?
    active_salesperson?
  end

  def update?
    active_salesperson?
  end
end
