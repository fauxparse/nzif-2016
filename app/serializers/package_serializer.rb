class PackageSerializer < ActiveModel::Serializer
  attributes :id, :name, :price
  has_many :allocations

  def price
    price = object.prices.current.amount
    {
      amount: price.format(symbol: false),
      symbol: price.currency.symbol,
      currency: price.currency.to_s
    }
  end
end
