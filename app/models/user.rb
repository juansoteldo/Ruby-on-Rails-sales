# frozen_string_literal: true

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

      if (reason == 'update' && !self.saved_change_to_marketing_opt_in?)
        return
      end

      creds       = Rails.application.credentials
      list_id     = Rails.env.development? ? creds.cm[:dev_list_id] : creds.cm[:prod_list_id]
      username    = creds.cm[:username]
      
      basic_auth = {
        username: username,
        password: 'whatever'
      }

      headers = {
        'Content-Type': 'application/json'
      }

      if marketing_opt_in?
        url = "https://api.createsend.com/api/v3.2/subscribers/#{list_id}.json"
        body = {
          'EmailAddress': email,
          'Resubscribe': true,
          'ConsentToTrack': 'Yes',
          'Name': first_name.to_s
        }

      else
        url = "https://api.createsend.com/api/v3.2/subscribers/#{list_id}/unsubscribe.json"
        body = {
          'EmailAddress': email
        }
      end
      
      HTTParty.post(url,
        basic_auth: basic_auth,
        headers: headers,
        body: body.to_json
      )
    end
end
