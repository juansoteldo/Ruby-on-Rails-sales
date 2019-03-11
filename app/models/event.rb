class Event < ActiveRecord::Base
  belongs_to :user
  belongs_to :request

  before_save :ensure_user
  before_save :create_request

  serialize :source

  accepts_nested_attributes_for :user
  accepts_nested_attributes_for :request

  def method_missing(symbol, *args)
    super(symbol, *args) unless source
    source.send(symbol, *args)
  end

  def self.from_params(params)
    params = params.with_indifferent_access
    event = Event.joins(:user).where(users: { email: params[:invitee_email] }).first
    event ||= Event.new uuid: params[:event_uuid] || SecureRandom.hex(16)
    event.source = params
    event.source_type = "params"
    event.starts_at = DateTime.parse(params[:event_start_time])
    event.ends_at = DateTime.parse(params[:event_end_time])
    event
  end

  def self.from_payload(payload)
    payload = payload.with_indifferent_access
    event = Event.find_by_uuid payload[:event][:uuid]
    event ||= Event.new uuid: payload[:event][:uuid]
    event.source = payload
    event.source_type = "payload"
    event.starts_at = DateTime.parse(payload[:event][:start_time])
    event.ends_at = DateTime.parse(payload[:event][:end_time])
    event
  end

  def source
    @source ||= read_attribute(:source).deep_transform_keys!(&:to_sym)
  end

  def invitee
    case source_type
    when "payload"
      @invitee ||= source[:invitee].deep_transform_keys!(&:to_sym)
    when "params"
      phone_number = source[:text_reminder_number]
      phone_number ||= source[:answer_1]
      {
          uuid: source[:invitee_uuid],
          email: source[:invitee_email],
          first_name: source[:invitee_first_name],
          last_name: source[:invitee_last_name],
          text_reminder_number: phone_number
      }
    else
      nil
    end
  end

  def source
    @source ||= read_attribute(:source).deep_transform_keys!(&:to_sym)
  end

  private

  def users_attributes
    return unless invitee

    {
        uuid: invitee[:uuid],
        email: invitee[:email],
        phone_number: invitee[:text_reminder_number],
    }
  end

  def requests_attributes
    return unless invitee
    {
        first_name: invitee[:first_name],
        last_name: invitee[:last_name],
        user_id: user_id
    }
  end

  def ensure_user
    if user_id
      user.update! users_attributes
    elsif possible_user
      self.user_id = possible_user.id
      possible_user.update! users_attributes
    else
      password = SecureRandom.hex(8)
      create_user! users_attributes.merge( password: password, password_confirmation: password )
    end
  end

  def create_request
    return if request_id
    create_request! requests_attributes
  end

  def possible_user
    User.where( "email ILIKE ? or phone_number = ?",
                invitee[:email], invitee[:text_reminder_number]).first
  end
end


=begin

Parameters included on calendly hook

  event_type_name
  event_type_uuid
  event_start_time (in invitee timezone (iso8601 format))
  event_end_time (in invitee timezone (iso8601 format))
  invitee_uuid
  invitee_email
  invitee_first_name (when applicable)
  invitee_last_name (when applicable)
  invitee_full_name (when applicable)
  invitee_payment_amount (when applicable)
  invitee_payment_currency (when applicable)
  utm_source (if available)
  utm_medium (if available)
  utm_campaign (if available)
  utm_content (if available)
  utm_term (if available)
  assigned_to
  text_reminder_number (if available)
  answer_1 (if available)
  answer_2 (if available)
  answer_3 (if available)
  answer_4 (if available)
  answer_5 (if available)
  answer_6 (if available)
  answer_7 (if available)
  answer_8 (if available)
  answer_9 (if available)
  answer_10 (if available)

=end