# frozen_string_literal: true

class Api::UsersController < Api::BaseController
  before_action :set_user, only: [:show, :update]

  def index
    @users = params[:email].to_s.empty? ? User.none : User.where(email: params[:email])
  end

  def show; end

  def update
    respond_to do |format|
      if @user.update(user_params)
        format.json { render :show, status: :ok, location: @user }
      else
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_user
    @user = User.where(email: params[:email]).first_or_create
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def user_params
    params.require(:user).permit(:presales_opt_in, :marketing_opt_in, :crm_opt_in)
  end
end
