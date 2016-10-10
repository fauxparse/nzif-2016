class PackagePriceList
  include MoneyHelper

  attr_reader :festival

  def initialize(festival)
    @festival = festival
  end

  def title
    I18n.t('prices.index.header', year: festival.year)
  end

  def prices
    packages.map { |package| PackagePricePresenter.new(package) }.sort
  end

  def to_ary
    prices
  end

  private

  def packages
    @packages ||= festival.packages.includes(:prices).all
  end

  class PackagePricePresenter
    def initialize(package)
      @package = package
    end

    def name
      package.name
    end

    def discounted?
      lowest_price < highest_price
    end

    def discounted_price
      lowest_price
    end

    def price
      highest_price
    end

    def to_partial_path
      "prices/package"
    end

    def <=>(another)
      price <=> another.price
    end

    private

    attr_reader :package

    def prices
      @prices ||= begin
        prices = package.prices.sort_by(&:amount)
        [*prices.select(&:available?), prices.last].map(&:amount).sort.uniq
      end
    end

    def lowest_price
      prices.first
    end

    def highest_price
      prices.last
    end
  end
end
