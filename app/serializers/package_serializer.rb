class PackageSerializer < ActiveModel::Serializer
  attributes :id, :name, :current_price
  has_many :allocations

  def current_price
    price = object.prices.current.amount
    {
      amount: price.format,
      currency: price.currency.to_s
    }
  end
end
