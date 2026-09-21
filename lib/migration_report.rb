class MigrationReport
  Issue = Struct.new(:level, :source, :locator, :message, :details, keyword_init: true)

  attr_reader :issues, :counters

  def initialize
    @issues   = []
    @counters = Hash.new(0)
  end

  def count(key, by = 1)
    @counters[key.to_sym] += by
  end

  def warn(source:, locator:, message:, **details)
    add(:warning, source, locator, message, details)
  end

  def error(source:, locator:, message:, **details)
    add(:error, source, locator, message, details)
  end

  def errors   = issues.select { |issue| issue.level == :error }
  def warnings = issues.select { |issue| issue.level == :warning }

  def to_s
    lines = []
    lines << "=== RAPPORT D'IMPORT ==="
    lines << ""

    lines << "Compteurs :"
    @counters.each do |key,value|
      lines << "  #{key} : #{value}"
    end
    lines << ""

    lines << "Erreurs (#{errors.count}) :"
    if errors.empty?
      lines << "  Aucune erreur."
    else
    errors.each do |issue|
      lines << " [#{issue.source}] #{issue.locator} — #{issue.message} "
    end
    end
    lines << ""

    lines << "Avertissements (#{warnings.count}) :"
    if warnings.empty?
      lines << "  Aucun avertissement."
    else
      warnings.each do |issue|
        lines << "  [#{issue.source}] #{issue.locator} — #{issue.message}"
      end
    end

    lines.join("\n")
  end

  private

  def add(level, source, locator, message, details)
    @issues << Issue.new(level: level, source: source, locator: locator,
                         message: message, details: details)
  end
end
