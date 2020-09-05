# frozen_string_literal: true

# Represents a single form request from the CTD site
class Request < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :tattoo_size, optional: true
  belongs_to :quoted_by, optional: true, class_name: "Salesperson"
  accepts_nested_attributes_for :user
  has_many :delivered_emails
  has_many :images, class_name: "RequestImage"
  has_one :event

  before_create :update_state_stamp
  after_update :update_user_names

  default_scope -> { includes(:user) }

  auto_strip_attributes :first_name, :last_name, :position

  scope :recent, (-> { where "created_at > ?", Rails.env.test? ? 1.seconds.ago : 5.minutes.ago })
  scope :newer_than_days, (->(days) { where "requests.created_at > ?", days.minutes.ago })
  scope :matching_email, (->(email) { joins(:user).where(users: { email: email }) })
  scope :deposited, (-> { where.not deposited_at: nil })
  scope :valid, (-> { where.not user_id: nil })
  scope :quoted_or_contacted_by, (->(salesperson_id) { where("quoted_by_id = ? OR contacted_by_id = ?", salesperson_id, salesperson_id) })
  scope :created_or_changed_between, (lambda { |start_time, end_time|
                                        where(
                                          "requests.created_at > ? AND state_changed_at BETWEEN ? AND ?", start_time, start_time, end_time
                                        )
                                      })
  scope :quoted, (-> { where.not(quoted_by_id: nil) })

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
    "Other"
  ].freeze

  TATTOO_STYLES = [
    "Traditional",
    "Custom Script",
    "Realistic",
    "Watercolor",
    "Tribal",
    "New School",
    "New Traditional",
    "Japanese",
    "Blackwork",
    "Illustrative",
    "Chicano"
  ].freeze

  state_machine :state, initial: :fresh do
    state :quoted
    state :fresh
    state :deposited
    state :completed

    event :quote do
      transition fresh: :quoted
    end

    event :convert do
      transition fresh: :deposited, quoted: :deposited
    end

    event :complete do
      transition any: :completed
    end

    after_transition on: :quote, do: :enqueue_quote_actions
    after_transition on: :convert, do: :enqueue_deposit_actions
    after_transition on: :complete, do: :perform_complete_actions
  end

  def self.relevant_date_range_for_order(order)
    return CTD::MIN_DATE..Time.now if Rails.env.test?

    created_at = order.created_at.to_date
    (created_at - 180.days)..(created_at + 7.days)
  end

  def self.find_and_attribute(label, method, *params)
    request = Request.send method, *params
    return nil unless request

    request.attributed_by ||= label
    request
  end

  def self.find_by_email(email, date_range: CTD::MIN_DATE..Time.now)
    joins(:user)
      .where(users: { email: email })
      .where(requests: { created_at: date_range }).last
  end

  def self.fuzzy_find_by_email(email, date_range: CTD::MIN_DATE..Time.now)
    joins(:user)
      .merge(User.fuzzy_matching_email(email))
      .where(requests: { created_at: date_range }).last
  end

  def quote_from_params!(params)
    return unless fresh?

    self.variant = params[:variant_id]
    self.quoted_by_id ||= params[:salesperson_id]
    save!
    quote!
  end

  def first_time?
    user.requests.where("created_at < ?", created_at).where.not(state: "fresh").none?
  end

  def sleeve?
    size&.include?("leeve")
  end

  def auto_quotable?
    return false unless Settings.emails.auto_quoting_enabled
    return true if sleeve?
    return false if size == "Extra Large"

    Request::TATTOO_STYLES.include?(style) && TattooSize.defined_size_names.include?(size)
  end

  def quote_from_attributes!
    return unless fresh?
    return unless auto_quotable?

    assign_tattoo_size_attributes
    self.quoted_by = Salesperson.system
    save!
    quote!
  end

  def assign_tattoo_size_attributes
    self.tattoo_size = TattooSize.for_request(self)
    self.variant = tattoo_size.deposit_variant_id
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
    state == "deposited" && deposit_order_id || state == "completed" && final_order_id || nil
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

      add_image_from_param(file)
      File.unlink(file) if File.exist?(file)
    end
  end

  def add_image_from_param(file)
    image = RequestImage.from_param(file)
    raise "#{file.truncate(128)} is not an image" unless image

    image.request_id = id
    image.save!
  rescue StandardError => e
    logger.error ">>> Cannot add image from #{file.truncate(128)}"
    logger.error e.message
    logger.error e.backtrace.join("\n")
    raise(e) if Rails.application.config.debugging
  end

  def send_confirmation_email
    Rails.logger.info "Sending confirmation email for request #{id}"
    BoxMailer.confirmation_email(self).deliver_later
  end

  def send_final_confirmation_email
    Rails.logger.info "Sending final confirmation email for request #{id}"
    BoxMailer.final_confirmation_email(self).deliver_later
  end

  def self.for_shopify_order(order, reset_attribution: false)
    request = find_and_attribute("request_id", :find_by_id, order.request_id.to_i) if order.request_id
    request ||= find_and_attribute("webhook", :find_by_deposit_order_id, order.id) unless reset_attribution || order.id.nil?
    unless order.email.to_s.empty?
      request ||= find_and_attribute("email", :find_by_email,
                                     order.email.downcase.strip,
                                     date_range: relevant_date_range_for_order(order))
    end
    unless order.email.to_s.empty?
      request ||= find_and_attribute("fuzzy_email", :fuzzy_find_by_email,
                                     order.email.downcase.strip,
                                     date_range: relevant_date_range_for_order(order))
    end
    return nil unless request
    return request unless reset_attribution || request.attributed_by.nil?

    request.save
    request
  end

  def ensure_streak_box
    return if streak_box_key

    CreateStreakBoxJob.perform_later(self)
  end

  def opt_in_user
    user.update presales_opt_in: true, crm_opt_in: true
    deliver_marketing_opt_in_email
  end

  def complete?
    return false unless user&.email&.present?
    return false unless user.first_name&.present?
    return false unless description&.present?

    true
  end

  def to_s
    "Request ##{id}"
  end

  private

  def deliver_marketing_opt_in_email
    return unless user.marketing_opt_in.nil?
    return unless user&.email

    BoxMailer.opt_in_email(self).deliver_later
  end

  def perform_complete_actions
    puts "Sending final confirmation email to #{user.email}" unless Rails.env.test?
    send_final_confirmation_email
  end

  def enqueue_quote_actions
    RequestActionJob.perform_later(request: self, method: "mark_last_box_quoted")
    return unless auto_quotable? && salesperson == Salesperson.system

    delay = Settings.emails.auto_quoting_delay
    RequestActionJob.set(wait: delay.minutes).perform_later(request: self, method: "send_quote")
  end

  def send_quote
    return unless quoted_at.nil?

    assign_tattoo_size_attributes unless tattoo_size
    raise "#{self} has no tattoo_size (style = #{style.inspect}, size = #{size.inspect})" unless tattoo_size

    quote = MarketingEmail.quote_for_request(self)
    raise "`send_quote` cannot determine quote for #{self} (style = #{style.inspect}, size = #{size.inspect})" unless quote

    self.quoted_at = Time.now
    save!
    BoxMailer.quote_email(self, quote).deliver_now
  end

  def enqueue_deposit_actions
    RequestActionJob.perform_later(request: self, method: "send_confirmation_email")
    RequestActionJob.perform_later(request: self, method: "mark_boxes_deposited")
  end

  def streak_boxes
    MostlyStreak::Box.query(user.email)
                     .select { |b| b.created_between?(created_at..(created_at + 2.days)) }
  end

  def mark_last_box_quoted
    box = streak_boxes.last
    return unless box

    current_stage = MostlyStreak::Stage.find(key: box.stage_key)
    return unless ["Contacted", "Leads"].include?(current_stage.name)

    quoted_by.claim_requests_with_email(user.email)
    box.set_stage("Quoted")
  end

  def mark_boxes_deposited
    streak_boxes.each do |box|
      current_stage = MostlyStreak::Stage.find(key: box.stage_key)
      next unless ["Contacted", "Leads", "Quoted"].include?(current_stage.name)

      box.set_stage("Deposited")
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

  def update_user_names
    return unless user

    user.update first_name: first_name || user.first_name, last_name: last_name || user.last_name
  end
end
