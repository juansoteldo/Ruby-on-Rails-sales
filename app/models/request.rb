class Request < ActiveRecord::Base
  belongs_to :user
  has_many :delivered_emails
  has_many :images, class_name: "RequestImage"

  before_create :update_state_stamp
  after_create :opt_in_user

  default_scope -> { includes(:user)}

  auto_strip_attributes :first_name, :last_name, :position

  scope :recent, (-> { where "created_at > ?", 5.minutes.ago })
  scope :deposited, (->{ where.not deposited_at: nil })
  scope :valid, (-> { where.not user_id: nil })
  scope :quoted_or_contacted_by, (->(salesperson_id){ where("quoted_by_id = ? OR contacted_by_id = ?", salesperson_id, salesperson_id) })

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
  ]

  state_machine :state, initial: :fresh do
    after_transition on: :convert, do: :perform_deposit_actions
    after_transition on: :complete, do: :perform_complete_actions

    event :convert do
      transition fresh: :deposited, quoted: :deposited
    end

    event :quote do
      transition fresh: :quoted
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

  def salesperson
    @salesperson ||= Salesperson.find(quoted_by_id) if quoted_by_id
    @salesperson ||= Salesperson.find(contacted_by_id) if contacted_by_id
    @salesperson
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
    (Time.zone.now - self.state_changed_at)
  end

  def art_sample_1=(file)
    add_wp_image(file)
  end

  def art_sample_2=(file)
    add_wp_image(file)
  end

  def art_sample_3=(file)
    add_wp_image(file)
  end

  def add_wp_image(file)
    return if file.empty?
    begin
      return unless File.exists?(file)
      if images.where("file LIKE ?", "%#{File.basename(file)}%").any?
        File.unlink file
        return
      end
      logger.info "Adding #{file}"
      images.create file: File.new(file)
    rescue => e
      logger.error ">>> Cannot add image to request #{file}"
      logger.error e.message
      logger.error e.backtrace.join("\n")
    ensure
      begin
        File.unlink file if File.exists?(file)
      rescue
        logger.error "Cannot delete image file at #{file}"
      end
    end
  end

  private

  def opt_in_user
    user&.update presales_opt_in: true, crm_opt_in: true
  end

  def perform_complete_actions
    puts "Sending final confirmation email to #{user.email}"
    BoxMailer.final_confirmation_email(self).deliver_later
  end

  def perform_deposit_actions
    puts "Sending confirmation email to #{user.email}"
    BoxMailer.confirmation_email(self).deliver_later
    begin
      StreakAPI::Box.query(user.email).each do |box|
        StreakAPI::Box.set_stage(box.key, 'Deposited')
      end
    rescue Exception => e
      Rails.logger.error "Cannot update streak box for request #{self.id} (#{e})"
    end

  end

  def subtotal
    return sub_total if sub_total
    return 0 if deposit_order_id.nil?

    order = Shopify::Order.find(deposit_order_id).first
    return 0 unless order
    self.update_column :sub_total, order.subtotal_price
    sub_total.to_f
  end

  def update_state_stamp
    self.state_changed_at = Time.zone.now
  end
end
