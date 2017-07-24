module ApplicationHelper
  def in_admin_panel?
    controller_path.split('/').first == 'admin'
  end

  def this_month
    (Time.now.beginning_of_month..Time.now)
  end

  def crm_start_url(request)
    crm_url = ENV.fetch "CRM_URL", "https://crm.customtattoodesign.ca"
    crm_url += "/preview/jobs/new?request_id=" + request.id.to_s
    crm_url
  end
end
