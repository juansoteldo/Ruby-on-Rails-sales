class Admin::SalespeopleController < Admin::BaseController

  before_action :require_admin

  def index
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
