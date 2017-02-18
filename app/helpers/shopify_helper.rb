module ShopifyHelper
  def product_css_classes(product)
      classes = []
      classes << 'final' if product.is_final_payment?
      classes << 'deposit' if product.is_deposit?
      classes.join(' ')
  end
end
