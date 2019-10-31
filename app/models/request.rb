# frozen_string_literal: true

class Request < ApplicationRecord
  belongs_to :user, optional: true
  accepts_nested_attributes_for :user
  has_many :delivered_emails
  has_many :images, class_name: "RequestImage"
  has_one :event

  before_create :update_state_stamp
  after_create :opt_in_user
  after_create_commit :deliver_marketing_opt_in_email

  default_scope -> { includes(:user) }

  auto_strip_attributes :first_name, :last_name, :position

  scope :recent, (-> { where "created_at > ?", Rails.env.test? ? 1.seconds.ago : 5.minutes.ago })
  scope :deposited, (-> { where.not deposited_at: nil })
  scope :valid, (-> { where.not user_id: nil })
  scope :quoted_or_contacted_by, (->(salesperson_id) { where("quoted_by_id = ? OR contacted_by_id = ?", salesperson_id, salesperson_id) })

  TATTOO_POSITIONS = [
    "Calf",
    "Chest",
    "Foot",
    "Fore Arm",
    "Full Back",
    "Full Sleeve",
    "Half Sleeve",
    "Leg",
    "Lower Back",
    "Ribs",
    "Stomach",
    "Upper Arm",
    "Upper Back",
    "Lower Arm",
    "Hip",
    "Wrist",
    "Ankle",
    "Other",
  ].freeze

  state_machine :state, initial: :fresh do
    after_transition on: :convert, do: :perform_deposit_actions
    after_transition on: :complete, do: :perform_complete_actions
    after_transition on: :quote, do: :perform_quote_actions

    event :quote do
      transition fresh: :quoted
    end

    event :convert do
      transition fresh: :deposited, quoted: :deposited
    end

    event :complete do
      transition any: :completed
    end

    state :quoted do
    end

    state :fresh do
    end

    state :deposited do
    end

    state :completed do
    end
  end

  def quote_from_params!(params)
    return unless fresh?
    self.variant = params[:variant_id]
    self.quoted_by_id ||= params[:salesperson_id]
    save! && quote!
  end

  def salesperson
    @salesperson ||= Salesperson.find(quoted_by_id) if quoted_by_id
    @salesperson ||= Salesperson.find(contacted_by_id) if contacted_by_id
    @salesperson
  end

  def fresh?
    state == "fresh"
  end

  def converted?
    ["deposited,completed"].include?(state)
  end

  def relevant_order_id
    state == 'deposited' && deposit_order_id || state == 'completed' && final_order_id || nil
  end

  def days_since_state_change
    (time_since_state_change / 1.day).to_i
  end

  def hours_since_state_change
    (time_since_state_change / 1.hour).to_i
  end

  def time_since_state_change
    (Time.zone.now - state_changed_at)
  end

  (1..10).each do |x|
    define_method("art_sample_#{x}=") do |file|
      return if file.to_s.empty?
      add_image_from_path(file)
      File.unlink(file) if File.exist?(file)
    end
  end

  def add_image_from_path(file)
    return unless File.exist?(file)

    logger.info "Adding #{file}"
    image = RequestImage.from_path(file)
    image.request_id = id
    image.save!
  rescue => e
    raise(e) if Rails.env.test?
    logger.error ">>> Cannot add image to request #{file}"
    logger.error e.message
    logger.error e.backtrace.join("\n")
  end

  def send_confirmation_email
    BoxMailer.confirmation_email(self).deliver_later
  end

  def send_final_confirmation_email
    BoxMailer.final_confirmation_email(self).deliver_later
  end

  def self.for_shopify_order(order, reset_attribution: false)
    email = order.email.downcase.strip
    attributed_by = "request_id"
    request = Request.where(id: order.request_id.to_i).first if order.request_id
    unless reset_attribution
      attributed_by = "webhook" unless request
      request ||= Request.find_by_deposit_order_id(order.id)
    end
    created_at = order.created_at.to_date
    date_range = (created_at - 180.days)..(created_at + 7.days)
    attributed_by = "email" unless request
    request ||= find_by_email(email, date_range: date_range)
    attributed_by = "fuzzy_email" unless request
    request ||= fuzzy_find_by_email(email, date_range: date_range)

    order.request_id = request&.id
    if request && (reset_attribution || request.attributed_by.nil?)
      request.update_column(:attributed_by, attributed_by)
    end
    request
  end

  private

  def self.find_by_email(email, date_range: CTD::MIN_DATE..Time.now)
    joins(:user).
      where(users: { email: email }).
      where(requests: { created_at: date_range }).last
  end

  def self.fuzzy_find_by_email(email, date_range: CTD::MIN_DATE..Time.now)
    joins(:user).
      merge(User.fuzzy_matching_email(email)).
      where(requests: { created_at: date_range }).last
  end

  def opt_in_user
    user.update presales_opt_in: true, crm_opt_in: true
  end

  def deliver_marketing_opt_in_email
    return unless user.marketing_opt_in.nil?
    BoxMailer.opt_in_email(self).deliver_later
  end

  def perform_complete_actions
    puts "Sending final confirmation email to #{user.email}" unless Rails.env.test?
    send_final_confirmation_email
  end

  def perform_quote_actions
    box = streak_boxes.last
    return unless box

    current_stage = MostlyStreak::Stage.find(key: box.stage_key)
    return unless current_stage.name == 'Contacted' || current_stage.name == 'Leads'

    MostlyStreak::Box.set_stage(box.key, 'Quoted')
  rescue Exception => e
    Rails.logger.error "Cannot update streak box for request #{id} (#{e})"
  end

  def streak_boxes
    MostlyStreak::Box.query(user.email).map do |box|
      Streak::Box.find(box.box_key)
    end.select do |box|
      box_created_at = Time.strptime(box.creation_timestamp.to_s, '%Q')
      (box_created_at - created_at) < 2.days
    end
  end

  def perform_deposit_actions
    Rails.logger.info "Sending confirmation email to #{user.email}"
    send_confirmation_email
    begin
      streak_boxes.each do |box|
        MostlyStreak::Box.set_stage(box.key, 'Deposited')
      end
    rescue Exception => e
      Rails.logger.error "Cannot update streak box for request #{id} (#{e})"
    end
  end

  def subtotal
    return sub_total if sub_total
    return 0 if deposit_order_id.nil?

    order = MostlyShopify::Order.find(deposit_order_id).first
    return 0 unless order
    update_column :sub_total, order.subtotal_price
    sub_total.to_f
  end

  def update_state_stamp
    self.state_changed_at = Time.zone.now
  end
end
