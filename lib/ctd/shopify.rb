module CTD
  class Shopify
    def self.update_all_data
      self.update_products_and_variants
      self.update_tattoo_sizes
    end

    def self.update_products_and_variants
      Product.destroy_all
      Variant.destroy_all
      products = ShopifyAPI::Product.all(session: AppConfig.shopify_session)
      for product in products
        Product.create(
          id: product.id,
          title: product.title,
          handle: product.handle
        )
        variants = product.variants
        for variant in variants
          Variant.create(
            id: variant.id,
            product_id: variant.product_id,
            title: variant.title,
            price: variant.price,
            fulfillment_service: variant.fulfillment_service,
            option1: variant.option1,
            option2: variant.option2,
            option3: variant.option3
          )
        end
      end
      puts 'Products and variants have been updated.'
    end
  
    def self.update_tattoo_sizes
      variants = Variant.where(option1: 'no', option2: 'no')
      for variant in variants
        next if variant.product_type != 'deposit'
        size = variant.size
        tattoo_size = TattooSize.find_by(name: size)
        if tattoo_size
          tattoo_size.update(deposit_variant_id: variant.id)
        end
      end
      puts 'Tattoo sizes have been updated.'
    end
  end
end
