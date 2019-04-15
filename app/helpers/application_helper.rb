module ApplicationHelper
  def in_admin_panel?
    controller_path.split('/').first == 'admin' && params[:layout].to_s != "0"
  end

  def this_month
    (Time.now.beginning_of_month..Time.now)
  end

  def crm_start_url(request)
    crm_url = CTD::CRM_URL
    crm_url + "/preview/jobs/new?request_id=" + request.id.to_s
  end

  def flash_class(level)
    case level.to_sym
    when :success then "alert alert-success"
    when :error then "alert alert-error"
    when :alert then "alert alert-error"
    else
      "alert alert-info"
    end
  end
end
