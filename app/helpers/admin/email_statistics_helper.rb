module Admin::EmailStatisticsHelper
  def box_mailer_types_without_marketing_email
    ["confirmation_email", "final_confirmation_email"]
  end

  def capitalize_and_split(word)
    word.split("_").map(&:capitalize).join(" ")
  end

  def all_message_of(mailer_type, template = nil, range = default_range)
    messages = ahoy_messages(range).where(utm_campaign: mailer_type)
    messages = messages.where(utm_content: template) if template.present?
    messages
  end

  def opened_messages(mailer_type, template = nil, range = default_range)
    all_message_of(mailer_type, template, range).where.not(opened_at: nil)
  end

  def clicked_messages(mailer_type, template = nil, range = default_range)
    all_message_of(mailer_type, template, range).where.not(clicked_at: nil)
  end

  def open_percentage_of(mailer_type, template = nil, range = default_range)
    percent_of(opened_messages(mailer_type, template, range).count, all_message_of(mailer_type, template, range).count)
  end

  def total_email_open_rate(range = default_range)
    percent_of(ahoy_messages(range).where.not(opened_at: nil).count, ahoy_messages(range).count)
  end

  def total_click_rate(range = default_range)
    percent_of(ahoy_messages(range).where.not(clicked_at: nil).count, ahoy_messages(range).count)
  end

  def click_percentage_of(mailer_type, template = nil, range = default_range)
    percent_of(clicked_messages(mailer_type, template, range).count, all_message_of(mailer_type, template, range).count)
  end

  def ahoy_messages(range = default_range)
    Ahoy::Message.where(sent_at: range)
  end

  def default_range
    [30.days.ago.beginning_of_day..Time.now]
  end

  def percent_of(x, n)
    return "-" unless n.positive?
    number_to_percentage(x.to_f / n.to_f * 100, precision: 0)
  end
end
