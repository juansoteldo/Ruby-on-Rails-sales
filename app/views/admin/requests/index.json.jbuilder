json.total @requests_count
json.rows do
  json.array!(@requests) do |request|
    json.extract! request, :created_at, :id, :user_id, :token, :is_first_time, :gender,
                  :has_color, :position, :client_id, :ticket_id, :linker_param, :_ga, :last_visited_at, :deposit_variant,
                  :deposit_order_id
    json.user do
      if request.user
        json.extract!(request.user, :id, :email)
      else
        json.id 0
        json.email 'Unmatched'
      end

    end
    json.url admin_request_url(request, format: :json)
  end
end

