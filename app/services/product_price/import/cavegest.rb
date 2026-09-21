class ProductPrice::Import::Cavegest < Importer::Base
  N = Importer::Normalization

  COLUMN_SEP = ";".freeze
  GRID_CODES = %w[DEPC CHR EXPO PART SALON].freeze

  def call
    imported = 0

    CSV.parse(File.read(path, encoding: "ISO-8859-1:UTF-8"), headers: true, col_sep: COLUMN_SEP, skip_lines: /^(CaveGest|$|---)/).each do |row|
      reference = N.text(row["Ref"])
      next if reference.nil?
      next if reference.start_with?("SOUS-TOTAL")

      product = Product.find_or_initialize_by(reference: reference)
        product.assign_attributes(
        name:      N.text(row["Désignation"]),
        color:     N.text(row["Couleur"]),
        volume_ml: volume_ml(row["Contenant"]),
        vat_rate:  N.decimal(row["TVA"]),
        stock:     N.decimal(row["Stock"]).to_i
      )

      if product.save
        import_prices(product, row)
        imported += 1
      else
        report.error(
         source:   source,
          locator:  N.text(row[0]),
          message:  "Produit rejeté : #{product.errors.full_messages.join(', ')}"
        )

      end
    end
    puts "#{imported} produits importés"

  end
    private

  def import_prices(product, row)
    GRID_CODES.each do |grid_code|
      amount = N.decimal(row[grid_code])

      # La grille EXPO est saisie en TTC dans CaveGest, on stocke du HT.
      amount /= 1.2 if grid_code == "EXPO"

      price = ProductPrice.find_or_initialize_by(product: product, grid_code: grid_code)
      price.amount_ht = amount.round(2)
      price.save
    end
  end



  def volume_ml(value)
    value.to_s[/\d+/].to_i * 10
  end
end
