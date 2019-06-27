# frozen_string_literal: true

class EmailPreferencesController < ApplicationController
  acts_as_token_authentication_handler_for User, fallback: :none
  before_action :authenticate_user!
  before_action :set_user, only: [:edit, :update]

  # GET /email_preferences/1/edit
  def edit
    authorize @user
  end

  # PATCH/PUT /email_preferences/1
  # PATCH/PUT /email_preferences/1.json
  def update
    authorize @user
    if @user.update!(email_preference_params)
      redirect_to edit_email_preference_url(@user), notice: 'Email preferences were successfully updated.'
    else
      render :edit
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_user
    head 404 && return unless current_user
    @user = User.find(current_user.id)
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def email_preference_params
    params.require(:user).permit(:presales_opt_in, :marketing_opt_in, :crm_opt_in)
  end
end
