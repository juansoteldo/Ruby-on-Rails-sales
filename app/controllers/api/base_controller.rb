class Api::BaseController < ApplicationController
    before_action :authenticate_token!

    private

    def authenticate_token!
      render text: "unauthorized" unless params[:token].present? && params[:token] == Settings.api.token
    end
end
