module CTD
  module Shopify
    class Variant < CTD::Shopify::Base
      def has_color?
        is_gift_card? && false || (@source.option1 == 'yes')
      end

      def has_cover_up?
        is_gift_card? && false || (@source.option2 == 'yes')
      end

      def is_gift_card?
        fulfillment_service == 'gift_card'
      end

    end
  end
end

require 'ctd/shopify/base'