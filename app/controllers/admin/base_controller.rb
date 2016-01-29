class Admin::BaseController < ApplicationController
  #devise
  before_filter :authenticate_admin!

  before_action :load_products

  private
  def current_ability
    @current_ability ||= AdminAbility.new current_admin
  end

  def load_products
    @groups = Shopify::Group.all
  end

end
