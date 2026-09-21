class Importer::Audit
  def self.call = new.call

  def call
    lines = []
    lines << "=== AUDIT D'IMPORT ==="
    lines << ""

    db_customers = Customer.count
    db_products = Product.count
    db_prices = ProductPrice.count

    lines << "Clients en base : #{db_customers}"
    lines << ""
    lines << "Produits en base : #{db_products}"
    lines << "Tarifs en base : #{db_prices}"
    lines << "Tarifs attendus (#{db_products} produits × 5 grilles) : #{db_products * 5}"
    if db_prices == db_products * 5
      lines << "Nombre de tarifs correct"
    else
      lines << "Écart détecté : #{db_products * 5 - db_prices} tarifs manquants"
    end

    nameless = Customer.where(company_name: nil, first_name: nil, last_name: nil).count
    lines << "Clients sans nom : #{nameless}" if nameless > 0

    lines.join("\n")
  end

  def to_s
    call.to_s
  end
end
