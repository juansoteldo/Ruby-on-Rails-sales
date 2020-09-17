# frozen_string_literal: true

class Admin::MarketingEmailsController < Admin::BaseController
  before_action :set_marketing_email, only: [:show]
  layout "marketing_email"

  def show
    @user = User.last
    @request = Request.quoted.where.not(tattoo_size_id: nil).last
    @variant = MostlyShopify::Variant.find(@request.tattoo_size.deposit_variant_id.to_i).first
    @user = @request.user

    if @marketing_email.email_type == "quote"
      @quote_template_path = "#{@marketing_email.template_path}/#{@marketing_email.template_name}"
      @template_path = "box_mailer/quote_email"
    else
      @template_path = "#{@marketing_email.template_path}/#{@marketing_email.template_name}"
    end
  end

  private

  def set_marketing_email
    @marketing_email = MarketingEmail.find(params[:id])
  end
end
