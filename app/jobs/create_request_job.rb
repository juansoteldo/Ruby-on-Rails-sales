# frozen_string_literal: true

# Creates a request based on form data
class CreateRequestJob < WebhookJob
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
    @request.update! params.merge(created_at: [@webhook.created_at, @request.created_at].min)
    return unless @request.complete?

    @request.ensure_streak_box
    @request.opt_in_user
  end

  private

  def set_user_by_email
    normalize_email!
    @user = User.find_by_email params[:email]
    if !@user
      password = SecureRandom.hex(8)
      @user = User.create! email: params[:email],
                           password: password, password_confirmation: password,
                           phone_number: params[:phone_number],
                           marketing_opt_in: !!params[:user_attributes][:marketing_opt_in]
    else
      @user.update!(job_status: 'undefined')
      CampaignMonitorActionJob.set(wait: 10.seconds).perform_later(user: @user, method: "add_or_update_user_to_all_list")
    end
    params[:user_attributes] ||= {}
    params[:user_attributes][:id] = @user.id
    params[:user_attributes][:email] = params.delete(:email)
    params[:user_attributes][:phone_number] = params.delete(:phone_number)
  end

  def normalize_email!
    raise "empty email" unless params.key?(:email)

    email = params[:email].to_s.downcase.strip
    raise "empty email" if email.blank?

    params[:email] = email
    params[:email]
  end
end
