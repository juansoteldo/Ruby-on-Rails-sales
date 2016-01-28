module ApplicationHelper
  def in_admin_panel?
    controller_path.split('/').first == 'admin'
  end
end
