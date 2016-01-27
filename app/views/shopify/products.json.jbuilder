json.total @products.count
json.rows do
  json.array!(@products) do |product|
    json.extract! product, :handle
  end
end
