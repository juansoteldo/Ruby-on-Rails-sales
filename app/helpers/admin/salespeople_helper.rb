module Admin::SalespeopleHelper
  def conversion_rate(salesperson, date_range)
    # total_count = box_count(salesperson, date_range)
    total_count = salesperson.requests.where(created_at: date_range).count
    return "-" unless total_count.positive?

    # number_to_percentage(sales_count(salesperson, date_range).to_f / total_count.to_f * 100, precision: 0)
    #      deposited_count = salesperson.deposited_requests.where( created_at: date_range ).count
    number_to_percentage(sales_count(salesperson, date_range) / total_count.to_f * 100, precision: 0)
  end

  def value_of_requests(salesperson, period)
    requests = salesperson.requests.deposited.where(created_at: period)
    sum = requests.map do |r|
      MostlyShopify::Variant.find(r.variant).first.price.to_f
    end.sum

    sum && number_to_currency(sum, precision: 0, unit: "") || ""
  end

  def deposits_month_to_date(salesperson)
    start_time = Time.now.beginning_of_month
    end_time = 1.day.ago.end_of_day
    value_of_requests salesperson, [start_time..end_time]
  end

  def deposits_last_month(salesperson)
    start_time = 1.month.ago.beginning_of_month
    end_time = 1.month.ago.end_of_month
    value_of_requests salesperson, [start_time..end_time]
  end

  def sales_exist(salesperson, date_range)
    SalesTotal.where(salesperson: salesperson, sold_on: date_range).any?
  end

  def sales_total(salesperson, date_range)
    SalesTotal.where(salesperson: salesperson,
                     sold_on: date_range).sum(:order_total)
  end

  def sales_count(salesperson, date_range)
    SalesTotal.where(salesperson: salesperson,
                     sold_on: date_range).sum(:order_count)
  end

  def box_count(salesperson, date_range)
    SalesTotal.where(salesperson: salesperson,
                     sold_on: date_range).sum(:box_count)
  end
  end
