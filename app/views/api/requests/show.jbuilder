json.extract! @request, :id, :has_color, :has_cover_up, :is_first_time,
              :position, :description, :variant, :sku, :notes, :sub_total,
              :first_name, :last_name, :deposit_order_id
json.email @request.user.email

json.images do
  json.array! @request.images do |image|

  end
end
