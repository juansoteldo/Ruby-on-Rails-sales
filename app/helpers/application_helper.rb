module ApplicationHelper
  def in_admin_panel?
    controller_path.split('/').first == 'admin' && params[:layout].to_s != "0"
  end

  def this_month
    (Time.now.beginning_of_month..Time.now)
  end

  def crm_start_url(request)
    crm_url = ENV.fetch "CRM_URL", "https://crm.customtattoodesign.ca"
    crm_url += "/preview/jobs/new?request_id=" + request.id.to_s
    crm_url
  end

  def flash_class(level)
    case level.to_sym
    when :notice then "alert alert-info"
    when :success then "alert alert-success"
    when :error then "alert alert-error"
    when :alert then "alert alert-error"
    end
  end
end
