class RequestCreateJob < ActiveJob::Base
  queue_as :webhook

  def perform(new_params)
    @params = new_params
    normalize_email
    validate_parameters
    set_user_by_email

    make_request!
  end

  def make_request!
    request_params

    @request = Request.recent.where(user_id: @user.id, position: params[:position]).first_or_create
    @request.update request_params
    @request.save!

    set_user_by_email if @user.nil?
    @user.requests << @request
  end

  private

  def params
    @params
  end


  def set_user_by_email
    if User.where( email: params[:email] ).any?
      @user =  User.find_by_email( params[:email] )
    else
      password = SecureRandom.hex(8)
      @user = User.create( email: params[:email], password: password, password_confirmation: password )
    end
  end

  def request_params
    params.permit(:client_id, :position, :gender,
                  :has_color, :is_first_time, :first_name, :last_name,
                  :linker_param, :_ga, :art_sample_1, :art_sample_2,
                  :art_sample_3, :description)
  end

  def validate_parameters
    [:position, :gender, :first_name, :last_name, :client_id ].each do |sym|
      render( json: false ) if params[sym] == '' or params[sym] == false
    end
  end

  def normalize_email
    if params[:email]
      params[:email] = params[:email].downcase.strip
    end
  end
end

