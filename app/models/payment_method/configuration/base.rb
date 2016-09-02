class PaymentMethod::Configuration::Base < ApplicationRecord
  self.table_name = 'payment_method_configurations'

  belongs_to :festival

  serialize :configuration, HashWithIndifferentAccess

  validates :type, uniqueness: { scope: :festival_id }

  class_attribute :configuration_options

  def payment_method
    PaymentMethod.const_get(self.class.payment_method_class_name)
  end

  def usable?
    true
  end

  def key
    self.class.key
  end

  def to_partial_path
    "payment_configurations/#{key}"
  end

  def self.key
    payment_method_class_name.underscore.to_sym
  end

  def self.inherited(subclass)
    super
    subclass.configuration_options = configuration_options.deep_dup
  end

  def self.configuration_attributes
    configuration_options.keys
  end

  private

  def self.payment_method_class_name
    name.demodulize.sub(/Configuration$/, '')
  end

  def self.configure_with(name, options = {})
    self.configuration_options ||= {}
    configuration_options[name.to_sym] = options

    eval <<~RUBY
      public

      def #{name}
        configuration[:#{name}] ||
          self.class.configuration_options[:#{name}][:default]
      end

      def #{name}=(value)
        configuration[:#{name}] = value
      end

      def #{name}?
        !#{name}.blank?
      end
    RUBY
  end

  configure_with :transaction_fee, default: 0
end
