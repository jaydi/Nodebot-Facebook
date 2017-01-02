class CancelRequestJob < ActiveJob::Base
  queue_as :default

  def perform(id)
    payment = Payment.find(id)
    return unless payment.cancel_request?

    unless Rails.env.test?
      res = Waikiki::HttpPersistent.post("#{APP_CONFIG[:iamport_api_url]}/users/getToken", {
        imp_key: APP_CONFIG[:iamport_api_key],
        imp_secret: APP_CONFIG[:iamport_api_secret]
      })
      token = JSON.parse(res.body)['response']['access_token']
      res = Waikiki::HttpPersistent.post("#{APP_CONFIG[:iamport_api_url]}/payments/cancel", {
        merchant_uid: payment.id,
        reason: '기한 만료'
      }, {'Authorization' => token})
      res = JSON.parse(res.body)

      if res['CODE'] == 0 and res['response']['status'] == 'cancelled'
        payment.succeed_cancel!
      else
        payment.update_attributes({failure_reason: res['message']})
        payment.fail_cancel!
      end
    else
      payment.succeed_cancel!
    end
  end
end