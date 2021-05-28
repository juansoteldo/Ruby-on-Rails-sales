module TaskHelper

  def self.yesno(var)
    var.present? ? 'Yes' : 'No'
  end

end