# frozen_string_literal: true

class Api::BaseController < ApplicationController
  before_action :authenticate_token!

  private

  def authenticate_token!
    @token = ENV.fetch("API_TOKEN","You have to set this")

    render text: "unauthorized" unless params[:token].present? && params[:token] == @token
  end
end
