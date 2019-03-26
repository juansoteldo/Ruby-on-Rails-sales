# frozen_string_literal: true

class Api::RequestImagesController < Api::BaseController
  skip_before_action :authenticate_token!, only: [:show]
  before_action :set_request_image, only: [:show]

  def show
    send_data @request_image.download_or_read,
              filename: @request_image.filename.to_s,
              type: @request_image.content_type
  end

  private

  def set_request_image
    if globally_authenticated
      @request_image = RequestImage.find(params[:id])&.decorate
    else
      @request_image = RequestImage.joins(:request).
        where("request_images.id = ? AND requests.uuid = ?", params[:id], params[:uuid]).first&.decorate
    end
    head 404 unless @request_image&.exists?
  end
end
