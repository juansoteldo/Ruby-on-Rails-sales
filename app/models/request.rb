class Request < ActiveRecord::Base
  belongs_to :user

  default_scope -> { includes(:user)}

  scope :recent, -> { where('created_at > ?', 5.minutes.ago)}
end
