class AdminConstraint
  def matches?(request)
    return false unless request.session[:salesperson_id]
    salesperson = Salesperson.find request.session[:salesperson_id]
    salesperson && salesperson.admin?
  end
end
