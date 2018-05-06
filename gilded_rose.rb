def update_quality(items)
  items.each(&:update_quality)
end

module LegendaryQualityUpdater
  def self.run(item)
    item.quality = 80
  end
end

module ConjuredQualityUpdater
  def self.run(item)
    item.quality -= 2
    item.quality -= 2 if item.sell_date_hit?
  end
end

module AgedBrieQualityUpdater
  def self.run(item)
    item.quality += 1
    item.quality += 1 if item.sell_date_hit?
  end
end

module StandardQualityUpdater
  def self.run(item)
    item.quality -= 1
    item.quality -= 1 if item.sell_date_hit?
  end
end

module BackstagePassQualityUpdater
  def self.run(item)
    item.quality += 1
    item.quality += 1 if item.sell_in < 11
    item.quality += 1 if item.sell_in < 6
    item.quality = 0 if item.sell_date_hit?
  end
end

class Item
  attr_reader :name
  attr_reader :quality
  attr_reader :sell_in

  def initialize(name, sell_in, quality)
    @name = name
    @sell_in = sell_in
    @quality = quality
    @quality_updater =
      case name
      when 'Sulfuras, Hand of Ragnaros'
        LegendaryQualityUpdater
      when 'Aged Brie'
        AgedBrieQualityUpdater
      when 'Backstage passes to a TAFKAL80ETC concert'
        BackstagePassQualityUpdater
      when 'Conjured Mana Cake'
        ConjuredQualityUpdater
      else
        StandardQualityUpdater
      end
    @legendary = (name == 'Sulfuras, Hand of Ragnaros')
  end

  def update_quality
    @quality_updater.run(self)
    @sell_in -= 1 unless @legendary
  end

  def sell_date_hit?
    sell_in <= 0
  end

  def quality=(quality)
    @quality = [quality, minimum_quality].max
    @quality = [@quality, maximum_quality].min
  end

  private

  def maximum_quality
    @legendary ? 80 : 50
  end

  def minimum_quality
    0
  end
end

# We use the setup in the spec rather than the following for testing.
#
# Items = [
#   Item.new("+5 Dexterity Vest", 10, 20),
#   Item.new("Aged Brie", 2, 0),
#   Item.new("Elixir of the Mongoose", 5, 7),
#   Item.new("Sulfuras, Hand of Ragnaros", 0, 80),
#   Item.new("Backstage passes to a TAFKAL80ETC concert", 15, 20),
#   Item.new("Conjured Mana Cake", 3, 6),
# ]

