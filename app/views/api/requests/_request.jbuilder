json.extract! request, :id, :has_color, :style, :size,
              :position, :description, :variant, :sku, :notes, :sub_total,
              :first_name, :last_name, :deposit_order_id, :deposited_at

json.has_cover_up request.has_cover_up && true || false
json.has_color request.has_color && true || false
json.is_first_time request.is_first_time && true || false

json.email request.user.email

if include_images
  json.images do
    json.array! request.images.decorate do |image|
      next unless image.exists?

      json.filename image.filename
      json.content_type image.content_type
      json.url api_request_image_url(image, uuid: request.uuid)
    end
  end
end
