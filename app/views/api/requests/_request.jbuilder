json.extract! request, :id, :has_color,
              :position, :description, :variant, :sku, :notes, :sub_total,
              :first_name, :last_name, :deposit_order_id, :deposited_at

json.has_cover_up request.has_cover_up && true || false
json.has_color request.has_color && true || false
json.is_first_time request.is_first_time && true || false

json.email request.user.email

if include_images
  json.images do
    json.array! request.images do |image|
      json.filename File.basename(image.file.path)
      json.content_type image.file.content_type
      json.url api_request_image_url(image, token: @token )
    end
    end
end
