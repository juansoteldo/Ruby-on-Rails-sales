# frozen_string_literal: true
require 'campaign_monitor'

class User < ApplicationRecord
  acts_as_token_authenticatable

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable,
         :registerable,
         :recoverable,
         :rememberable,
         :trackable,
         :validatable

  scope :fuzzy_matching_email, (->(email) { where("levenshtein(email, ?) <= 2", email) })
  scope :subscribed_to_marketing, -> { where(marketing_opt_in: true) }

  has_many :requests, dependent: :destroy
  has_many :requests, dependent: :destroy
  has_many :events
  has_many :messages, class_name: "Ahoy::Message"

  auto_strip_attributes :email, :first_name, :last_name
  phony_normalize :phone_number, default_country_code: "US"

  after_save do |u| 
    u.update_cm_status(:save)
  end

  after_create do |u| 
    u.update_cm_status(:create)
  end

  before_validation :initialize_password
  validates_presence_of :email
  validates_length_of :email, minimum: 5

  def ransackable_attributes(_auth_object = nil)
    [:email, :marketing_opt_in, :crm_opt_in, :presales_opt_in]
  end

  def email=(value)
    self[:email] = value&.downcase
  end

  def opted_out
    !presales_opt_in && !marketing_opt_in
  end

  def opted_out=(value)
    assign_attributes(presales_opt_in: !value, marketing_opt_in: !value)
    assign_attributes(crm_opt_in: !value) unless value
  end

  def initialize_password
    return unless password.blank?

    self.password = SecureRandom.base64(12)
  end

  def identifies_as
    requests.take.gender
  end

  protected

    def update_cm_status(reason)
      return if (reason == 'update' && !self.saved_change_to_marketing_opt_in?)
      CampaignMonitor.export_user_data(self)
    end

end