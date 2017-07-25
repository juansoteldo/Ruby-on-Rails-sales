class Api::RequestsController < Api::BaseController
  before_action :set_request, only: [:show]

  def index
    @requests = Request.where(deposited_at: [7.days.ago..Time.now]).order(deposited_at: :desc)
  end

  def show; end

  private

  def set_request
    @request = Request.find params[:id]
  end
end
