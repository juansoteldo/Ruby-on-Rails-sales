class RequestCreateJob < ActiveJob::Base
  queue_as :webhook

  def perform(new_params)
    @params = new_params

    set_user_by_email
    make_request!
  end

  def make_request!
    @request = Request.recent.where(user_id: @user.id,
                                    position: params[:position]).first_or_create
    @request.assign_attributes params
    @request.save!

    @user.requests << @request
  end

  private

  def params
    @params
  end

  def set_user_by_email
    normalize_email!
    if User.where(email: params[:email]).any?
      @user =  User.find_by_email params.delete(:email)
    else
      password = SecureRandom.hex(8)
      @user = User.create email: params.delete(:email),
                          password: password, password_confirmation: password
    end
  end

  def normalize_email!
    raise "empty email" if params[:email].nil?
    params[:email] = params[:email].downcase.strip
    raise "empty email" if params[:email] == ""
    params[:email]
  end
end

