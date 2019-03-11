# frozen_string_literal: true

class Admin::BaseController < ApplicationController
  before_action :authenticate_salesperson!
  before_action :load_products

  private

  def current_ability
    @current_ability ||= AdminAbility.new(current_admin)
  end

  def load_products
    @groups = Shopify::Group.all
  end

end
