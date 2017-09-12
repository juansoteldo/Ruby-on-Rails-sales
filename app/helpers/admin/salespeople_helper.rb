  module Admin::SalespeopleHelper
    def conversion_rate(salesperson, period)
      total_requests = salesperson.requests.where( requests: { created_at: period } ).count
      deposited_requests = salesperson.deposited_requests.where(requests: { created_at: period }).count

      number_to_percentage(deposited_requests.to_f / total_requests.to_f * 100, precision: 0)
    end

    def value_of_requests(salesperson, period)
      requests = salesperson.deposited_requests.where( created_at: period )
      sum = requests.map do |r|
        Shopify::Variant.find(r.variant).first.price.to_f
      end.sum

      sum && number_to_currency(sum, precision: 0, unit: '') || ''
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

    def sales_total( salesperson, date_range )
      SalesTotal.where(salesperson: salesperson,
                       sold_on: date_range).sum(:order_total)
    end

    def sales_count( salesperson, date_range )
      SalesTotal.where(salesperson: salesperson,
                       sold_on: date_range).sum(:order_count)
    end

  end
