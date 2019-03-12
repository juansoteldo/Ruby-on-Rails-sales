# frozen_string_literal: true

class Api::BaseController < ApplicationController
  before_action :authenticate_token!

  private

  def authenticate_token!
    render text: "unauthorized" unless globally_authenticated
    session[:globally_authenticated] = true
  end

  def globally_authenticated
    @globally_authenticated ||= params[:token].present? && params[:token] == global_token
  end

  def global_token
    @global_token ||= ENV.fetch("API_TOKEN","You have to set this")
  end
end
