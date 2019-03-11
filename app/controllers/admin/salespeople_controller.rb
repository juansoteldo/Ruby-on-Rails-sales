# frozen_string_literal: true

class Admin::SalespeopleController < Admin::BaseController
  before_action :require_admin

  def index
    @statistic_parameters = {
      3.months.ago.strftime("%B").to_sym => {
        range: (3.month.ago.beginning_of_month..3.month.ago.end_of_month),
      },
      2.months.ago.strftime("%B").to_sym => {
        range: (2.month.ago.beginning_of_month..2.month.ago.end_of_month),
      },
      1.months.ago.strftime("%B").to_sym => {
        range: (1.month.ago.beginning_of_month..1.month.ago.end_of_month),
      },
      Time.zone.now.strftime("%B").to_sym => {
        range: (Time.zone.now.beginning_of_month..Time.zone.now),
      },
    }
    @salespeople = Salesperson.all
  end

  def new
    @salesperson = Salesperson.new
  end

  def create
    @salesperson = Salesperson.new salesperson_params

    if salesperson.save
      redirect_to [:admin, :salespeople], notice: "Salesperson created"
    else
      render :new
    end
  end

  def edit
  end

  def update
    if salesperson.update_attributes salesperson_params
      redirect_to [:admin, :salespeople], notice: "Salesperson updated"
    else
      render :edit
    end
  end

  private

  def require_admin
    unless current_salesperson && current_salesperson.admin?
      redirect_to [:admin, :root], notice: "Access denied"
    end
  end

  helper_method :salesperson

  def salesperson
    @salesperson ||= Salesperson.find params[:id]
  end

  def salesperson_params
    params.require(:salesperson).permit(
      :email,
      :password,
      :password_confirmation,
      :streak_api_key,
      :user_key,
      :is_active,
      :admin
    )
  end
end
