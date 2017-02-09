module PaymentHelper
  def pay_url(user, payment_id, vendor)
    "#{APP_CONFIG[:host_url]}/payments/#{payment_id}?user_id=#{user.id}&vendor=#{vendor}"
  end
end