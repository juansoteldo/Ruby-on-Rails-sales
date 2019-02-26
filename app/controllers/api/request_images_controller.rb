class Api::RequestImagesController < Api::BaseController
  before_action :set_request_image, only: [:show]

  def show
    send_data @request_image.file.read, filename: File.basename(@request_image.file.path),
              type: @request_image.file.content_type
  end

  private

  def set_request_image
    @request_image = RequestImage.find params[:id]
  end
end