class RequestImageDecorator < Draper::Decorator
  delegate_all

  # Define presentation-specific methods here. Helpers are accessed through
  # `helpers` (aka `h`). You can override attributes, for example:
  #
  #   def created_at
  #     helpers.content_tag :span, class: 'time' do
  #       object.created_at.strftime("%a %m/%d/%y")
  #     end
  #   end

  def exists?
    file&.attached? || carrier_wave_file&.file&.exists? || false
  end

  def download_or_read
    if file.attached?
      file.download
    elsif carrier_wave_file&.file&.exists?
      carrier_wave_file.read
    else
      nil
    end
  end

  def filename
    if file.attached?
      file.filename
    elsif carrier_wave_file&.file&.exists?
      File.basename(carrier_wave_file.path)
    else
      nil
    end
  end

  def content_type
    if file.attached?
      file.content_type
    elsif carrier_wave_file&.file&.exists?
      carrier_wave_file.content_type
    else
      nil
    end
  end

  def url
    if file.attached?
      url_for(file)
    elsif carrier_wave_file&.file&.exists?
      carrier_wave_file.url
    else
      nil
    end
  end
end
