json.extract! user, :id, :email, :presales_opt_in, :marketing_opt_in, :crm_opt_in, :job_status, :created_at, :updated_at
json.url api_user_path(user, format: :json)
