# frozen_string_literal: true

class Api::RequestsController < Api::BaseController
  before_action :set_request, only: [:show, :update]
  skip_before_action :authenticate_token!, only: [:update]

  def index
    days = params[:days].present? ? params[:days].to_i : 60
    @requests = Request.where(deposited_at: [days.days.ago..Time.now]).order(deposited_at: :desc)
  end

  def show; end

  def update
    if @request.update(request_params)
      render json: @request, status: :created, location: [:api, @request ]
    else
      render json: @request.errors, status: :unprocessable_entity
    end
  end

  private

  def set_request
    if globally_authenticated
      @request = Request.includes(:user).where(id: params[:id]).first
    else
      @request = Request.includes(:user).where(id: params[:id], token: params[:token]).first
    end
    raise "not-found" unless @request
  end

  def request_params
    params.require(:request).permit :client_id, :first_name, :last_name
  end
end
