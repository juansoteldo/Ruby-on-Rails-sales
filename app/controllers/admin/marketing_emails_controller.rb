# frozen_string_literal: true

class Admin::MarketingEmailsController < Admin::BaseController
  before_action :set_marketing_email, only: [:show]
  layout "mailer"

  def show
    @user = User.last
    @request = Request.quoted.where.not(tattoo_size_id: nil).last
    @variant = MostlyShopify::Variant.find(@request.tattoo_size.deposit_variant_id.to_i).first
    @variant = MostlyShopify::VariantDecorator.decorate(@variant)
    @user = @request.user
  end

  private

  def set_marketing_email
    @marketing_email = MarketingEmail.find(params[:id])&.decorate
  end
end
