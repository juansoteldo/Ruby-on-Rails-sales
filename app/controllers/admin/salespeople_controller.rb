class Admin::SalespeopleController < Admin::BaseController
  load_and_authorize_resource :request, class: Request

  before_action :set_request, only: [:show, :edit, :update, :destroy]

  # GET /salespeople
  # GET /salespeople.json
  def index
    @dates = {}
    @dates[:created_at_max] = params[:date_max] if params[:date_max]
    @dates[:created_at_min] = params[:date_min] if params[:date_min]
    if params[:date_max] and params[:date_min]
      @date_range = "#{params[:date_min]} - #{params[:date_max]}"
    elsif params[:date_max]
      @date_range = "Before #{params[:date_max]}"
    elsif params[:date_min] 
      @date_range = "Since #{params[:date_min]}"
    else
      @date_range = "Since all time"
    end
    @salespeople = Salesperson.sales_by_date(@dates)
  end

  # GET /salespeople/1
  # GET /salespeople/1.json
  def show
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_request
      @request = Request.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def request_params
      params.require(:request).permit(:user_id, :token, :is_first_time, :gender, :has_color, :position, :notes, :quote_id, :client_id, :ticket_id)
    end
end
