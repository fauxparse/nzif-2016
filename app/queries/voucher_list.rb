class VoucherList
  attr_reader :festival

  def initialize(festival)
    @festival = festival
  end

  def to_ary
    scope.all.sort_by(&:participant)
  end

  def find(id)
    scope.find(id)
  end

  def scope
    festival.vouchers.includes(:participant)
  end
end
