# frozen_string_literal: true

class Api::BaseController < ApplicationController
  before_action :authenticate_token!

  private

  def authenticate_token!
    head 401 unless globally_authenticated
    session[:globally_authenticated] = true
  end

  def globally_authenticated
    @globally_authenticated ||= params[:token].present? && params[:token] == global_api_token
  end

  def global_api_token
    @global_api_token ||= Settings.ctd.global_api_token
  end
end
