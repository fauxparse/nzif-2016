class PackageSerializer < ActiveModel::Serializer
  attributes :id, :name, :price
  has_many :allocations

  def price
    price = current_price.amount
    {
      amount: price.format(symbol: false),
      symbol: price.currency.symbol,
      currency: price.currency.to_s
    }
  end

  private

  def current_price
    object.prices.sort.detect(&:available?) || object.prices.last
  end
end
