# frozen_string_literal: true

class Api::RequestImagesController < Api::BaseController
  skip_before_action :authenticate_token!, only: [:show]
  before_action :set_request_image, only: [:show]

  def show
    send_data @request_image.file.read, filename: File.basename(@request_image.file.path),
              type: @request_image.file.content_type
  end

  private

  def set_request_image
    if globally_authenticated
      @request_image = RequestImages.find(params[:id])
    else
      @request_image = RequestImage.joins(:request).where("request_images.id = ? AND requests.uuid = ?", params[:id], params[:uuid]).first
    end
    raise "not-found" unless @request_image
  end
end