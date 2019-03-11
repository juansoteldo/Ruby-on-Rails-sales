# frozen_string_literal: true

class Api::RequestsController < Api::BaseController
  before_action :set_request, only: [:show]

  def index
    days = params[:days].present? ? params[:days].to_i : 60
    @requests = Request.where(deposited_at: [days.days.ago..Time.now]).order(deposited_at: :desc)
  end

  def show; end

  private

  def set_request
    @request = Request.includes(:user).where(id: params[:id]).first
    raise "not-found" unless @request
  end
end
