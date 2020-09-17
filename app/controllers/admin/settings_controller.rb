# frozen_string_literal: true

class Admin::SettingsController < Admin::BaseController
  before_action :set_setting

  def update
    authorize @setting
    respond_to do |format|
      if @setting.update setting_params
        format.html { redirect_to admin_salespeople_path, notice: "Setting saved." }
        format.json { render :show, status: 200, location: admin_salespeople_path }
      else
        format.html { redirect_to admin_salespeople_path, notice: "Setting cannot be saved." }
        format.json { render json: setting.errors, status: :unprocessable_entity }
      end
    end
  end

  private

  def set_setting
    @setting = Setting.find params[:id]
  end

  def setting_params
    params.require(:setting).permit :value
  end
end
