# frozen_string_literal: true

class Admin::UsersController < Admin::BaseController
  before_action :require_admin!
  before_action :set_cache_headers

  # GET /users
  # GET /users.json
  def index
    @users = policy_scope(User).order(email: :asc)
    @q = @users.ransack(params[:q])
    @users = @q.result(distinct: true)

    respond_to do |format|
      format.html { @users = @users.paginate(:page => params[:page]) }
      format.csv
    end
  end

  def set_cache_headers
    response.headers["Cache-Control"] = "no-cache, no-store"
    response.headers["Pragma"] = "no-cache"
    response.headers["Expires"] = "Fri, 01 Jan 1990 00:00:00 GMT"
  end
end
