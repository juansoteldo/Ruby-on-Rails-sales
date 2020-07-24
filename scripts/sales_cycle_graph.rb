funnel = {}
require "ascii_charts"

data =  Request.unscoped.select("ROUND(DATE_PART('day', deposited_at - created_at)), id").group("ROUND(DATE_PART('day', deposited_at - created_at))").where("deposited_at IS NOT NULL").count("id")
total = Request.unscoped.where("deposited_at IS NOT NULL").count

data = data.to_a.sort_by(&:first)
puts data.inspect
data = data.map do |value|
  [value.first, (value.last.to_f / total.to_f * 100)]
end
puts AsciiCharts::Cartesian.new(data).draw
# Request.deposited.each do |request|
#  days = (request.deposited_at - request.created_at).round
#  funnel[days] = 0 unless funnel.key?(days)
#  funnel[days] += 1
# end

# puts funnel.inspect
