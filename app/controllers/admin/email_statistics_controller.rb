class Admin::EmailStatisticsController < Admin::BaseController
  
  def index
    @emails = Ahoy::Message.order("id DESC")
  end

end