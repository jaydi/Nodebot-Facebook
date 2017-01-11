module PaymentHelper
  def payment_url(user, payment_id, vendor)
    if user.user_agreements_accepted?
      "#{APP_CONFIG[:host_url]}/payments/#{payment_id}?user_id=#{user.id}"
    else
      "#{APP_CONFIG[:host_url]}/users/agreements?id=#{user.id}&pending_payment_id=#{payment_id}&vendor=#{vendor}"
    end
  end
end