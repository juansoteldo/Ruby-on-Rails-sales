# frozen_string_literal: true

class Admin::MarketingEmailsController < Admin::BaseController
  before_action :set_marketing_email, only: [:show, :edit, :update]

  def edit
    authorize(Admin::MarketingEmailsController)
  end

  def update
    authorize(Admin::MarketingEmailsController)
    respond_to do |format|
      if @marketing_email.update marketing_email_params
        format.html { redirect_to admin_marketing_email_path(@marketing_email), notice: "Updated marketing email." }
        format.json { render :show, status: 200, location: admin_marketing_email_path(@marketing_email) }
      else
        format.html { redirect_to edit_admin_marketing_email_path(@marketing_email), notice: "Cannot save your changes." }
        format.json { render json: @marketing_email.errors, status: :unprocessable_entity }
      end
    end
  end

  def show
    authorize(Admin::MarketingEmailsController)
    @user = User.last
    @request = Request.quoted.where.not(tattoo_size_id: nil).last
    @variant = Variant.find(@request.tattoo_size.deposit_variant_id.to_i)
    @variant = MostlyShopify::VariantDecorator.decorate(@variant)
    @user = @request.user
  end

  private

  def set_marketing_email
    @marketing_email = MarketingEmail.find(params[:id])&.decorate
  end

  def marketing_email_params
    params.require(:marketing_email).permit :subject_line, :from, :markdown_content
  end
end
