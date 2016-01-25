json.array!(@product_variants) do |product_variant|
  json.extract! product_variant, :id, :product_id, :shopify_id, :has_color, :has_cover_up
  json.url product_variant_url(product_variant, format: :json)
end
