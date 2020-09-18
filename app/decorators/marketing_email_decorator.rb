# frozen_string_literal: true

# Decorates the Event class for the UI
class MarketingEmailDecorator < Draper::Decorator
  delegate_all

  def html_content(request, variant = nil)
    renderer = Redcarpet::Render::HTML.new(hard_wrap: true)
    markdown = Redcarpet::Markdown.new(renderer, autolink: true)
    markdown.render(replace_constants(markdown_content.to_s, request, variant))
  end

  def text_content(request, variant = nil)
    markdown = Redcarpet::Markdown.new(Redcarpet::Render::StripDown)
    markdown.render(replace_constants(markdown_content.to_s, request, variant))
  end

  private

  def replace_constants(content, request, variant)
    content.gsub! "{{Request.first_name}}", request.first_name.try(:titleize)
    content.gsub! "{{Request.size}}", request.size
    if variant
      content.gsub! "{{Variant.price}}", variant.formatted_price
      content.gsub! "{{Variant.cart_redirect_url}}", variant.cart_redirect_url(request)
    end
    content
  end
end
