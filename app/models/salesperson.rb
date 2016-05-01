class Salesperson < ActiveRecord::Base

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

attr_accessor :orders, :total_sales

def self.all_with_shopify_orders(params)
		params = { limit: 250 } if !params
		orders = Shopify::Order.shopify_orders(params)
    mapped_orders = orders.map do |order|
      order.sales_id = ""
      order.note_attributes.each do |note_attr|
        if note_attr.name == "sales_id"
          order.sales_id = note_attr.value
        end
      end
      order
    end
    grouped_orders = mapped_orders.group_by(&:sales_id).select{|id,orders| id != "" }.map do |id, orders|
      c = self.find(id.to_i)
      c.total_sales = orders.inject(0) {|sum,o| sum + o.total_price.to_f.round(2)}
      c.orders = orders
      c
    end
    return grouped_orders
end
def self.sales_by_date(params)
	params[:limit] = 250 
	self.all_with_shopify_orders(params)
end

end