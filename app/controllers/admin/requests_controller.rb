class Admin::RequestsController < Admin::BaseController
  load_and_authorize_resource :request, class: Request

  before_action :set_request, only: [:show, :edit, :update, :destroy]

  # GET /requests
  # GET /requests.json
  def index
    @requests = Request.joins(:user).order( created_at: :desc )

    if params[:search]
      term = params[:search].downcase
      @requests = @requests.
          where( 'LOWER(users.email) LIKE ? OR LOWER(requests.first_name) LIKE ? OR LOWER(requests.last_name) LIKE ? OR requests.client_id LIKE ?',
                 "%#{term}%", "%#{term}%", "%#{term}%", "%#{term}%" )
    end
    @requests = @requests.where('requests.created_at > ?', Date.strptime(params[:after])) if params[:after]
    @requests = @requests.where('requests.created_at < ?', Date.strptime(params[:before])) if params[:before]

    @requests_count = @requests.count
    @requests = @requests.limit(params[:limit]) if params[:limit]
    @requests = @requests.offset(params[:offset]) if params[:offset]
  end

  # GET /requests/1
  # GET /requests/1.json
  def show
  end

  # GET /requests/new
  def new
    @request = Request.new
  end

  # GET /requests/1/edit
  def edit
  end

  # POST /requests
  # POST /requests.json
  def create
    @request = Request.new(request_params)

    respond_to do |format|
      if @request.save
        format.html { redirect_to @request, notice: 'Request was successfully created.' }
        format.json { render :show, status: :created, location: @request }
      else
        format.html { render :new }
        format.json { render json: @request.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /requests/1
  # PATCH/PUT /requests/1.json
  def update
    respond_to do |format|
      if @request.update(request_params)
        format.html { redirect_to @request, notice: 'Request was successfully updated.' }
        format.json { render :show, status: :ok, location: @request }
      else
        format.html { render :edit }
        format.json { render json: @request.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /requests/1
  # DELETE /requests/1.json
  def destroy
    @request.destroy
    respond_to do |format|
      format.html { redirect_to requests_url, notice: 'Request was successfully destroyed.' }
      format.json { head :no_content }
    end
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
