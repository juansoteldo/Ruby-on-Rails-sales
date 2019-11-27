# frozen_string_literal: true

class RequestImage < ApplicationRecord
  belongs_to :request, optional: true
  has_one :user, through: :request

  mount_uploader :carrier_wave_file, RequestImageUploader
  has_one_attached :file

  def self.from_param(value)
    if base64?(value)
      from_base64(value)
    elsif value.to_s =~ URI.regexp
      from_uri(value)
    elsif File.exist?(value)
      from_path(value)
    end
  end

  def self.from_path(path)
    image = new
    image.file.attach io: File.open(path),
                      filename: File.basename(path)
    image
  end

  def self.from_uri(uri)
    image = new
    image.file.attach io: open(uri),
                      filename: File.basename(uri.to_s)
    image
  end

  def self.from_base64(value)
    base64_data = value.split("base64,")[1] || return
    extension = get_extension(value) || return
    image = new
    file = Tempfile.new(["request-image", ".#{extension}"])
    data = Base64.decode64(base64_data)
    data = data.force_encoding("UTF-8")
    file.write data
    file.close
    image.file.attach io: file.open,
                      filename: File.basename(file.path)
    file.unlink
    image
  rescue => e
    raise e if Rails.env.test?
    file&.path&.unlink if File.exist?(file.path)
    nil
  end

  def self.get_extension(value)
    regex = /data:image\/([a-z]{3,4});.+/
    m = value.match regex
    m ? m[1] : nil
  end

  def self.base64?(value)
    return false unless value.is_a?(String)
    value.start_with?("data:image/") || Base64.encode64(Base64.decode64(value)) == value
  end
end
