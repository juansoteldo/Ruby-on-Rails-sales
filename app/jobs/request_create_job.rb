# frozen_string_literal: true

class RequestCreateJob < WebhookJob
  def perform(args)
    super
    set_user_by_email
    make_request!
    @webhook.commit! @request.id
    @request
  end

  def make_request!
    @request = Request.recent.where(user_id: @user.id,
                                    position: params[:position]).first_or_create
    @request.update! params
    return if @request.description.to_s.empty?
    @request.ensure_streak_box
    @request.opt_in_user
    return if @request.created_at < @webhook.created_at
    @request.update_column(:created_at, @webhook.created_at)
  end

  private

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
    raise "empty email" unless params.key?(:email)
    email = params[:email].to_s.downcase.strip
    raise "empty email" if email.blank?
    params[:email] = email
    params[:email]
  end
end

