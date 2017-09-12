module Admin::EmailStatisticsHelper
  def box_mailer_types_without_marketing_email
    ["confirmation_email","final_confirmation_email"]
  end

  def capitalize_and_split(word)
    word.split("_").map(&:capitalize).join(" ")
  end
  
  def all_message_of(mailer_type, template = nil)
    Ahoy::Message.where(utm_campaign: mailer_type, utm_content: template) if template.present?
    Ahoy::Message.where(utm_campaign: mailer_type)
  end

  def message_opened(mailer_type, template = nil)
    if template.present?
      Ahoy::Message.where(utm_campaign: mailer_type, utm_content: template).where.not(opened_at: nil) 
    end
    Ahoy::Message.where(utm_campaign: mailer_type).where.not(opened_at: nil)
  end

  def message_unopened(mailer_type, template = nil)
    Ahoy::Message.where(utm_campaign: mailer_type, opened_at: nil, utm_content: template) if template.present?
    Ahoy::Message.where(utm_campaign: mailer_type, opened_at: nil) 
  end

  def open_percentage_of(mailer_type, template = nil)
    percent_of(message_opened(mailer_type, template).count ,all_message_of(mailer_type, template).count)
  end

  def unopened_percentage_of(mailer_type, template = nil)
    percent_of(message_unopened(mailer_type, template).count ,all_message_of(mailer_type, template).count)
  end

  def percent_of(x,n)
    x.to_f / n.to_f * 100.0
  end

  def total_email_unopened_rate
    percent_of(Ahoy::Message.where(opened_at: nil).count, Ahoy::Message.count)
  end

  def total_email_open_rate
    percent_of(Ahoy::Message.where.not(opened_at: nil).count, Ahoy::Message.count)
  end

  def total_click_rate
     percent_of(Ahoy::Message.where.not(clicked_at: nil).count, Ahoy::Message.count)
  end

  def message_clicked(mailer_type, template = nil)
    if template.present?
      Ahoy::Message.where(utm_campaign: mailer_type, utm_content: template).where.not(clicked_at: nil) 
    end
    Ahoy::Message.where(utm_campaign: mailer_type).where.not(clicked_at: nil)
  end

  def click_percentage_of(mailer_type, template = nil)
    percent_of(message_clicked(mailer_type, template).count ,all_message_of(mailer_type, template).count)
  end


end