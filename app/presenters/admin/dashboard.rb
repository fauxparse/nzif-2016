class Admin::Dashboard
  attr_reader :festival

  def initialize(festival)
    @festival = festival
  end

  def to_partial_path
    'dashboard'
  end

  def workshops
    @workshops ||= ActivitySummary.new(festival, Workshop)
  end

  def shows
    @shows ||= ActivitySummary.new(festival, Show)
  end

  def payments
    @payments ||= PaymentSummary.new(festival)
  end

  private

  class ActivitySummary
    include Rails.application.routes.url_helpers

    attr_reader :festival, :type

    def initialize(festival, type)
      @festival = festival
      @type = type
    end

    def title
      type.model_name.human.pluralize
    end

    def to_partial_path
      'activity_summary'
    end

    def report_link
      send(:"admin_#{type.name.underscore}_reports_path", festival)
    end

    def places
      festival.activities
        .joins(:schedules)
        .where('activities.type' => type.name)
        .sum('schedules.maximum')
    end

    def taken
      festival.selections
        .joins(:schedule => :activity)
        .where('activities.type' => type.name)
        .count
    end
  end

  class PaymentSummary
    attr_reader :festival

    def initialize(festival)
      @festival = festival
    end

    def to_partial_path
      'payment_summary'
    end

    def accounts
      @accounts ||= registrations.map { |r| Account.new(r) }
    end

    def registrations
      @registrations ||= festival.registrations.complete
        .includes(:payments, :package => :prices)
    end

    def total
      accounts.sum(Money.new(0), &:total)
    end

    def received
      accounts.sum(Money.new(0), &:total_paid_excluding_vouchers) + voucher_total
    end

    def rows
      Payment.payment_methods.map { |payment_method| row(payment_method) }
    end

    def voucher_total
      festival.vouchers.to_a.sum(Money.new(0), &:amount)
    end

    private

    class Row
      attr_reader :registrations, :payment_method

      def initialize(registrations, payment_method, vouchers)
        @registrations = registrations
        @payment_method = payment_method
        @vouchers = vouchers
      end

      def name
        payment_method.model_name.human
      end

      def received
        payments.select(&:approved?).sum(Money.new(0), &:amount)
      end

      def total
        payments
          .select { |payment| payment.approved? || payment.pending? }
          .sum(Money.new(0), &:amount)
      end

      private

      def vouchers
        @vouchers_by_registration || @vouchers.each.with_object({}) do |voucher, vouchers|
          registration = registrations.detect { |r| r.participant_id == voucher.participant_id }

          if registration.present?
            (vouchers[registration.id] ||= []).push voucher
          end
        end
      end

      def payments
        @payments ||= registrations.select(&:complete?).flat_map do |registration|
          registration.payments.select do |payment|
            payment.payment_method.class == payment_method
          end
        end
      end
    end

    def row(payment_method)
      Row.new(registrations, payment_method, festival.vouchers)
    end
  end
end
