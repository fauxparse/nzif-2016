class PaymentList
  attr_reader :festival

  def initialize(festival, params)
    @festival = festival
    @filter = params[:filter] || 'pending'
  end

  def tabs
    @tabs ||= Payment.statuses.keys.map do |status|
      Tab.new(festival, status, @filter == status)
    end
  end

  def active_tab
    tabs.detect(&:selected?) || tabs.first
  end

  def payments
    active_tab.scope.map { |payment| Presenter.new(festival, payment) }
  end

  alias_method :to_ary, :payments

  private

  class Tab
    include Rails.application.routes.url_helpers

    def initialize(festival, status, selected)
      @festival = festival
      @status = status
      @selected = !!selected
    end

    def selected?
      @selected
    end

    def label
      I18n.t("admin.payments.index.#{@status}")
    end

    def path
      filtered_admin_payments_path(@festival, @status)
    end

    def scope
      @festival.payments.send(@status)
    end
  end

  class Presenter < SimpleDelegator
    alias_method :payment, :__getobj__
    attr_reader :festival

    def initialize(festival, payment)
      super(payment)
      @festival = festival
    end

    def date
      created_at.to_date
    end

    def reference
      to_param
    end
  end
end
