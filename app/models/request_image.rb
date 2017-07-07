class RequestImage < ActiveRecord::Base
  belongs_to :request

  mount_uploader :file, RequestImageUploader

  validates_presence_of :file
  #validates_integrity_of :file
end
