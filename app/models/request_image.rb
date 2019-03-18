# frozen_string_literal: true

class RequestImage < ApplicationRecord
  belongs_to :request, optional: true
  has_one :user, through: :request

  mount_uploader :carrier_wave_file, RequestImageUploader
  has_one_attached :file

  def self.from_path(path)
    image = self::new
    image.file.attach io: File.open(path),
                filename: File.basename(path)
    image
  end
end
