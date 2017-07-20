class Api::BaseController < ApplicationController
    before_action :authenticate_token!

    private

    def authenticate_token!
      render text: "unauthorized" unless params[:token].present? &&
          params[:token] == ENV.fetch("API_TOKEN","You have to set this")
    end
end
