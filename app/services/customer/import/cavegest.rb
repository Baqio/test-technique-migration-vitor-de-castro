class Customer::Import::Cavegest < Importer::Base
  N = Importer::Normalization

  KINDS = { "C" => "customer", "F" => "supplier", "P" => "prospect", "R" => "customer" }.freeze

  def call
    imported = 0

    (2..sheet.last_row).each do |i|
        row = sheet.row(i)
      next if row[0].nil?
      next if row[0].to_s == "TOTAL"

      customer = Customer.new(
        reference:         N.text(row[0]),
        company_name:      N.text(row[3]),
        first_name:        N.text(row[2]),
        last_name:         N.text(row[1]),
        address1:          N.text(row[4]),
        city:              N.text(row[6]),
        zip:               N.zip(row[5]),
        country_code:      N.country_code(row[7]),
        phone:             row[9].to_s,
        mobile:            row[10].to_s,
        email:             row[8].to_s,
        kind:              KINDS[N.text(row[19])],
        customer_category: N.text(row[20]),
        price_grid_code:   N.text(row[21]),
        vat_number:        N.text(row[23]),
        excise_number:     N.text(row[24]),
        shipping_last_name:    N.text(row[11]),
        shipping_first_name:   N.text(row[12]),
        shipping_company_name: N.text(row[13]),
        shipping_address1:     N.text(row[14]),
        shipping_zip:          N.zip(row[15]),
        shipping_city:         N.text(row[16]),
        shipping_country_code: N.country_code(row[17]),
        shipping_phone:        row[18].to_s,
        use_billing_address:   row[11].nil? && row[14].nil?
      )


      if customer.save
        imported += 1
        report.count(:customers_imported)
      else
        report.error(
         source:   source,
          locator:  N.text(row[0]),
          message:  "Client rejeté : #{customer.errors.full_messages.join(', ')}"
        )

      end
    end

    puts "#{imported} clients importés"
  end


  private

  def sheet
    @sheet ||= Roo::Excelx.new(path).sheet(0)
  end
end
