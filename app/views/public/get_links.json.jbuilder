json.user_id @user.id

json.requests(@user.requests) do |request|
  json.id request.id
  json.user_id request.user_id
  json.client_id request.client_id
  json.linker_param request.linker_param
  json._ga request._ga
  json.sales_id @salesperson.id if @salesperson
  json.gender request.gender
  json.position request.position
  json.name "#{request.first_name} #{request.last_name}"
  json.has_color request.has_color
  json.has_cover request.has_cover_up
end

json.groups(@groups) do |group|
  json.title group.title
  json.id group.id
  json.products group.products do |product|
    json.id product.id
    json.title product.title
    json.is_deposit product.is_deposit?
    json.variants product.variants do |variant|
      json.id variant.id
      json.price variant.price
      json.has_color variant.color?
      json.has_cover variant.cover_up?
      json.url cart_redirect_url(product.handle, variant.id, clientId: "", linkerParam: "", requestId: "", _ga: "", uid: "")
    end
  end
end
