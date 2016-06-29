json.total @salespeople.count
json.rows do
  json.array!(@salespeople) do |person|
    json.extract! person, :total_sales, :email
    json.date_range @date_range
    json.total_orders person.orders.count
  end
end
