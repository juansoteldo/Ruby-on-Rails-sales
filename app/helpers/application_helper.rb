module ApplicationHelper
  def in_admin_panel?
    controller_path.split('/').first == 'admin'
  end

  def this_month
    (Time.now.beginning_of_month..Time.now)
  end
end
