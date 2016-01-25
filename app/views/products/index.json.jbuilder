json.array!(@products) do |product|
  json.extract! product, :id, :name, :type, :slug
  json.url product_url(product, format: :json)
end
