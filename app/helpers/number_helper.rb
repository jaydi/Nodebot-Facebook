module NumberHelper
  def currency_format(number)
    number_to_currency(number, delimiter: ",", precision: 0, format: '%n%u', unit: "원")
  end
end