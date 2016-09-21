require 'csv'

class AccountingReport
  attr_reader :festival

  def initialize(festival)
    @festival = festival
  end

  def to_csv
    CSV.generate do |csv|
      csv << columns.map(&:title)

      accounts.each do |registration|
        csv << columns.map { |column| column.fetch(registration) }
      end
    end
  end

  def filename
    [
      festival.name.to_url,
      'accounts',
      Time.zone.now.strftime('%Y-%m-%d-%H-%M-%S')
    ].join('-') + '.csv'
  end

  private

  def columns
    @columns ||= [
      RawColumn.new('Name', :registration, :participant, :name),
      RawColumn.new('Email', :registration, :participant, :email),
      RawColumn.new('Package', :registration, :package, :name),
      MoneyColumn.new('Total', :total),
      MoneyColumn.new('Internet Banking', :total_paid_by_internet_banking),
      MoneyColumn.new('PayPal', :total_paid_by_paypal),
      MoneyColumn.new('Vouchers', :total_paid_by_voucher),
      MoneyColumn.new('Paid', :total_paid),
      MoneyColumn.new('To Pay', :total_to_pay)
    ]
  end

  def registrations
    @registrations ||= festival.registrations.complete
      .includes(:selections, :payments, :participant => :user, :package => :prices)
      .order('participants.name')
  end

  def accounts
    @accounts ||= registrations.map { |registration| Account.new(registration) }
  end

  class RawColumn
    attr_reader :title, :keys

    def initialize(title, *keys)
      @title = title
      @keys = keys
    end

    def fetch(row)
      keys.inject(row) { |object, key| object.send(key) }
    end
  end

  class MoneyColumn < RawColumn
    def fetch(row)
      super.format(symbol: false, no_cents_if_whole: false)
    end
  end
end
