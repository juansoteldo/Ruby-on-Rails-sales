# frozen_string_literal: true

class Admin::BaseController < ApplicationController
  before_action :authenticate_salesperson!
  before_action :load_products

  private

  def pundit_user
    current_salesperson
  end

  def load_products
    @groups = Shopify::Group.all
  end

end
