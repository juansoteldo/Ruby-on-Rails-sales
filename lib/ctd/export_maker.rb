module CTD
  class ExportMaker
    def self.make_xlsx!(requests)
      path = get_file_path("xlsx")
      workbook = FastExcel.open(path, constant_memory: true)
      workbook.default_format.set(
        font_size: 0, # user's default
        font_family: "Arial"
      )

      worksheet = workbook.add_worksheet("Requests")

      worksheet.append_row HEADER_ROW

      requests.find_in_batches do |group|
        group.each do |request|
          worksheet.append_row(
            [
              request.created_at.in_time_zone("EST"),
              request.user.email,
              request.user.marketing_opt_in,
              request.is_first_time,
              request.gender,
              request.has_color,
              request.has_cover_up,
              request.style,
              request.size,
              request.position,
              request.large,
              request.deposit_order_id,
              request.sub_total
            ]
          )
        end
      end
      workbook.close
      workbook
    end

    def self.make_csv!(requests)
      path = get_file_path("csv")
      CSV.open(path, "w") do |csv|
        csv << HEADER_ROW
        requests.find_in_batches do |group|
          group.each do |request|
            csv <<
              [
                request.created_at.in_time_zone("EST"),
                request.user.email,
                request.user.marketing_opt_in,
                request.is_first_time,
                request.gender,
                request.has_color,
                request.has_cover_up,
                request.style,
                request.size,
                request.position,
                request.large,
                request.deposit_order_id,
                request.sub_total
              ]
          end
        end
      end
      path
    end

    def self.get_file_path(extension)
      path = Rails.root.join("tmp", "requests.#{extension}")
      File.unlink(path) if File.exist?(path)
      path
    end

    HEADER_ROW = [
      "Created At",
      "E-Mail",
      "Opted-in",
      "First Time?",
      "Gender",
      "Color?",
      "Cover Up?",
      "Style",
      "Size",
      "Position",
      "Large?",
      "Shopify Oder",
      "Subtotal"
    ].freeze
  end
end
