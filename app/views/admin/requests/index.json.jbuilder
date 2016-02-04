json.total @requests_count
json.rows do
  json.array!(@requests) do |request|
    json.extract! request, :created_at, :id, :user_id, :token, :is_first_time, :gender,
                  :has_color, :position, :client_id, :ticket_id, :linker_param, :_ga
    json.user do
      json.extract!(request.user, :id, :email)
    end
    json.url admin_request_url(request, format: :json)
  end
end

