module CTD
  module Shopify
    class Base
      def initialize(source)
        @source = source
      end

      def method_missing(symbol, *args)
        @source.send(symbol, *args)
      end
    end
  end
end