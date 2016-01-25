json.total @requests_count
json.rows do
  json.array!(@requests) do |request|
    json.extract! request, :id, :user_id, :token, :is_first_time, :gender, :has_color, :position, :notes, :qid, :requesting_cid, :ticket_url
    json.user do
      json.extract!(request.user, :email)
    end
    json.url request_url(request, format: :json)
  end
end

