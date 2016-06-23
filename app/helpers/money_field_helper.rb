module MoneyFieldHelper
  def money_field(name, amount, options = {})
    content_tag :label, :class => "money-field" do
      concat content_tag(:span, amount.currency.symbol)
      concat number_field_tag(name, humanized_money(amount))
      concat content_tag(:span, options[:after]) if options[:after]
    end
  end
end
