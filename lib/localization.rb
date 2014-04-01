# Represents an abstract localisation
# Generated by parsing a localization file from an app
# Used to generate localization files for use in an app
class Localization

  attr_reader :key, :value

  def initialize(key, value)
    @key, @value = key, value
  end

  alias_method :text, :value

  def to_a
    [key, value]
  end

  include Comparable
  def <=> other
    return [key, value] <=> [other.key, other.value]
  end

  def self.create_master_texts(localizations)
    localizations.each do |localization|
      LocalizedTextEnforcer::MasterTextCrudder.create_or_update!(localization.key, localization.text)
    end
  end

  class Collection
    def keys
      localizations.map(&:key)
    end

    def to_a
      localizations.dup
    end

    def to_hash
      Hash[localizations.map { |l| [l.key, l] }]
    end

    def each(&block)
      localizations.each(&block)
    end
  end
end