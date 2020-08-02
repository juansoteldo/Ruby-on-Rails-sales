module ShopifyHelper
  def product_css_classes(product)
    classes = []
    classes << "final" if product.final_payment?
    classes << "deposit" if product.deposit?
    classes.join(" ")
  end
end
