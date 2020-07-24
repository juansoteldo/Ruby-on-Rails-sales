# frozen_string_literal: true

class Admin::SalespeopleController < Admin::BaseController
  def index
    @statistic_parameters = {
      3.months.ago.strftime("%B").to_sym => {
        range: (3.month.ago.beginning_of_month..3.month.ago.end_of_month)
      },
      2.months.ago.strftime("%B").to_sym => {
        range: (2.month.ago.beginning_of_month..2.month.ago.end_of_month)
      },
      1.months.ago.strftime("%B").to_sym => {
        range: (1.month.ago.beginning_of_month..1.month.ago.end_of_month)
      },
      Time.zone.now.strftime("%B").to_sym => {
        range: (Time.zone.now.beginning_of_month..Time.zone.now)
      }
    }
    @salespeople = policy_scope(Salesperson)
  end

  def new
    @salesperson = Salesperson.new
    authorize @salesperson
  end

  def create
    @salesperson = Salesperson.new salesperson_params
    authorize @salesperson

    if salesperson.save
      redirect_to %i[admin salespeople], notice: "Salesperson created"
    else
      render :new
    end
  end

  def edit
    authorize salesperson
  end

  def update
    if salesperson.update_attributes salesperson_params
      redirect_to %i[admin salespeople], notice: "Salesperson updated"
    else
      render :edit
    end
  end

  private

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
