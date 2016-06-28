module MoneyHelper
  def m(amount)
    content_tag :span, class: "money" do
      concat content_tag(:span, amount.format)
      concat content_tag(:abbr, amount.currency.to_s)
    end if amount
  end
end
