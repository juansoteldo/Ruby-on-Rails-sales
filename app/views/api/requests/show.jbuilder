json.extract! @request, :id, :has_color,
              :position, :description, :variant, :sku, :notes, :sub_total,
              :first_name, :last_name, :deposit_order_id

json.has_cover_up @request.has_cover_up && true || false
json.has_color @request.has_color && true || false
json.is_first_time @request.is_first_time && true || false

json.email @request.user.email

json.images do
  json.array! @request.images do |image|

  end
end
