# frozen_string_literal: true

class Admin::UsersController < Admin::BaseController

  # GET /users
  # GET /users.json
  def index
    @users = policy_scope(User).order(email: :desc)
    respond_to do |format|
      format.html { @users = @users.paginate(:page => params[:page]) }
      format.csv
    end
  end
end
