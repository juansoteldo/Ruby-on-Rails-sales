class SaveEmailJobArguments
  include ActiveModel::Validations
  include ActiveModel::Validations::Callbacks
  include ActiveModel::Conversion
  extend ActiveModel::Naming
  extend AutoStripAttributes

  attr_accessor :salesperson
  attr_accessor :salesperson_email
  attr_accessor :recipient_email
  auto_strip_attributes :recipient_email, virtual: true

  validates :recipient_email, presence: true,
                              format: { with: URI::MailTo::EMAIL_REGEXP, message: "recipient email is invalid" }
  validates :salesperson, presence: true

  def initialize(attributes = {})
    attributes.each do |name, value|
      send("#{name}=", value)
    end
  end

  def salesperson_email=(value)
    return unless value =~ URI::MailTo::EMAIL_REGEXP

    @salesperson = Salesperson.find_by_email(value)
  end

  def valid?
    self.recipient_email = recipient_email.downcase
    super
  end

  def persisted?
    false
  end

  def to_h
    { salesperson: salesperson, recipient_email: recipient_email }
  end
end
