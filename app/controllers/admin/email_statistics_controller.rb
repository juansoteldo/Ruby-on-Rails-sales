# frozen_string_literal: true

class Admin::EmailStatisticsController < Admin::BaseController

  def index
    authorize(Admin::EmailStatisticsController)
  end

end