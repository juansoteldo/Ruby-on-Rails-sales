# frozen_string_literal: true

class RequestImage < ApplicationRecord
  belongs_to :request, optional: true

  mount_uploader :file, RequestImageUploader

  validates_presence_of :file
  validates_integrity_of :file
end
