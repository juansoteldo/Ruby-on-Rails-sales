# frozen_string_literal: true

class User < ApplicationRecord
  acts_as_token_authenticatable

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable


  has_many :requests, dependent: :destroy
  has_many :events
  has_many :messages, class_name: "Ahoy::Message"

  auto_strip_attributes :email, :first_name, :last_name
  phony_normalize :phone_number, default_country_code: 'US'

  validates_presence_of :email
  validates_length_of :email, minimum: 5

  def ransackable_attributes(auth_object = nil)
    [:email, :marketing_opt_in, :crm_opt_in, :presales_opt_in]
  end

  def email=(value)
    self[:email] = value&.downcase&.strip
  end

  def opted_out
    !presales_opt_in && !marketing_opt_in
  end

  def opted_out=(value)
    assign_attributes(presales_opt_in: !value, marketing_opt_in: !value)
    assign_attributes(crm_opt_in: !value) unless value
  end

end
