json.total @requests_count
json.rows do
  json.array!(@requests) do |request|
    json.extract! request, :created_at, :id, :user_id, :uuid, :is_first_time, :gender,
                  :has_color, :position, :client_id, :ticket_id, :linker_param, :_ga, :last_visited_at,
                  :deposit_variant, :deposit_order_id
    json.user do
      if request.user
        json.extract!(request.user, :id, :email, :presales_opt_in,
                      :marketing_opt_in, :crm_opt_in, :opted_out)
      else
        json.id 0
        json.email 'Unmatched'
      end

    end

    json.images do
      json.array!(request.images.decorate) do |image|
        next unless image.exists?
        json.url api_request_image_url(image, uuid: request.uuid )
      end
    end
    json.url admin_request_path(request, format: :json)
    json.crm_url crm_start_url(request)
    json.send_confirmation_path send_confirmation_admin_request_path(request)
  end
end

