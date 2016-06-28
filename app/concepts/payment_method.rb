class PaymentMethod
  extend ActiveModel::Naming

  def self.key
    name.underscore
  end
end
