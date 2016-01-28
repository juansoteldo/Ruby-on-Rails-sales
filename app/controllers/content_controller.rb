class ContentController < ApplicationController
  def admin
    flash.keep
    redirect_to admin_requests_url
  end
end
