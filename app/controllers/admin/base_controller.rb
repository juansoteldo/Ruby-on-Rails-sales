# frozen_string_literal: true

class Admin::BaseController < ApplicationController
  before_action :authenticate_salesperson!
  before_action :load_products

  def require_admin!
    return if current_salesperson&.admin?

    redirect_to "/404.html"
  end

  private

  def pundit_user
    current_salesperson
  end

  def load_products
    @groups = MostlyShopify::Group.all
  end
end
