class RequestImageDecorator < Draper::Decorator
  delegate_all
  include CtdSales::Application.routes.url_helpers
  include ActionView::Helpers::UrlHelper

  def exists?
    file&.attached? || carrier_wave_file&.file&.exists? || false
  end

  def download_or_read
    if file.attached?
      file.download
    elsif carrier_wave_file&.file&.exists?
      carrier_wave_file.read
    end
  end

  def filename
    if file.attached?
      file.filename
    elsif carrier_wave_file&.file&.exists?
      File.basename(carrier_wave_file.path)
    end
  end

  def content_type
    if file.attached?
      file.content_type
    elsif carrier_wave_file&.file&.exists?
      carrier_wave_file.content_type
    end
  end

  def url
    Rails.application.routes.default_url_options[:host] = ENV["APP_HOST"]
    if file.attached?
      url_for(file)
    elsif carrier_wave_file&.file&.exists?
      carrier_wave_file.url
    end
  end
end
