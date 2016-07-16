class PaymentMethod
  include Cry
  extend ActiveModel::Naming

  def created(payment)
    publish(:success, payment)
  end

  def self.key
    name.underscore
  end
end
