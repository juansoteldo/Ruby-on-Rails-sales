module CTD
  class ProductImporter
    def initialize

    end

    def import(csv_path)
      @csv = CSV.foreach( csv_path, headers: true ) do |row|
        if row['Title'] != ''
          product = Product.find_or_create_by( handle: row['Handle']  ).tap do |p|
            p.name = row['Title']
            p.is_deposit = row['Handle'].contains?('deposit')
            p.is_final_payment = row['Handle'].contains?('final')

          end
        end
      end
    end

    def parse_csv!
      @csv.each
    end

  end
end

require 'csv'