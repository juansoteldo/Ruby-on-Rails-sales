class Setting < ApplicationRecord
  serialize :value
  before_validation :assign_default

  def respond_to_missing?
    true
  end

  def method_missing(method)
    by_name(method)
  end

  def self.auto_quoting
    by_name("Auto-quoting")
  end

  def self.by_name(name)
    find_by_name(name)
  end

  def value
    data_type == "boolean" ? super.to_s.downcase == "true" : super
  end

  def value=(value)
    data_type == "boolean" ? super(value.to_s.downcase == "true") : super(value)
  end

  def assign_default
    self.value ||= data_type == "boolean" ? false : ""
  end
end
