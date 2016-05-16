module DatesHelper
  def date_range(start_date, end_date)
    return strip_leading_zeroes(l(start_date, format: :range_same_day)) \
      if start_date == end_date

    key = if start_date.year != end_date.year
            :years
          elsif start_date.month != end_date.month
            :months
          elsif start_date.day != end_date.day
            :days
          end

    [
      l(start_date, format: :"range_#{key}_start"),
      l(end_date, format: :"range_#{key}_end")
    ].map(&method(:strip_leading_zeroes)).join
  end

  private

  def strip_leading_zeroes(date_string)
    date_string.gsub(/\b0/, "")
  end
end
