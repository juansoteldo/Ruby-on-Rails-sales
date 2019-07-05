class RequestCreateJob < ApplicationJob
  queue_as :webhook

  def perform(new_params)
    @params = new_params

    set_user_by_email
    make_request!
  end

  def make_request!
    @request = Request.recent.where(user_id: @user.id,
                                    position: params[:position]).first_or_create
    @request.update! params
  end

  private

  def params
    @params
  end

  def set_user_by_email
    normalize_email!
    @user = if User.where(email: params[:email]).any?
              User.find_by_email params[:email]
            else
              password = SecureRandom.hex(8)
              User.create! email: params[:email],
                           password: password, password_confirmation: password
            end
    params[:user_attributes] ||= {}
    params[:user_attributes][:id] = @user.id
    params[:user_attributes][:email] = params.delete(:email)

    return unless params[:user_attributes].key?(:marketing_opt_in)
    params[:user_attributes][:marketing_opt_in] = params[:user_attributes][:marketing_opt_in] == "0" ? false : nil
    @user.update params[:user_attributes]
  end

  def normalize_email!
    raise "empty email" if params[:email].nil?
    params[:email] = params[:email].downcase.strip
    raise "empty email" if params[:email] == ""
    params[:email]
  end
end

