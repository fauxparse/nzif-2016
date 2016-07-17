class PaymentMethod
  include Cry
  extend ActiveModel::Naming
  extend ActiveModel::Translation

  def created(payment)
    publish(:success, payment)
  end

  def self.key
    name.demodulize.underscore
  end
end
