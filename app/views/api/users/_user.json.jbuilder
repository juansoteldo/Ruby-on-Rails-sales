json.extract! user, :id, :email, :presales_opt_in, :marketing_opt_in, :crm_opt_in, :created_at, :updated_at
json.url user(user, format: :json)
