class Request < ActiveRecord::Base
  belongs_to :user
  has_many :delivered_emails
  has_many :images, class_name: "RequestImage"

  before_create :update_state_stamp

  default_scope -> { includes(:user)}

  scope :recent, -> { where('created_at > ?', 5.minutes.ago)}

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
    logger.info "Adding #{file}"
    begin
      if File.exists?(file)
        images.create file: File.new(file)
        File.unlink file
      else
        raise "Request Image can't be found"
        false
      end
    rescue
      logger.error ">>> Cannot add image to request #{file}"
    end
  end

  private

  def perform_complete_actions
    puts "Sending final confirmation email to #{user.email}"
    BoxMailer.final_confirmation_email(self).deliver_now
  end

  def perform_deposit_actions
    puts "Sending confirmation email to #{user.email}"
    BoxMailer.confirmation_email(self).deliver_now
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
