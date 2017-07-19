class Api::RequestsController < Api::BaseController
  before_action :set_request, only: [:show]

  def index

  end

  def show

  end

  private

  def set_request
    @request = Request.find params[:id]
  end
end
