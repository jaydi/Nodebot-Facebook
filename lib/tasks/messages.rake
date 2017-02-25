namespace :messages do

  desc '답장가능 메시지 알림'
  task :notice => :environment do
    paid_messages_map = Message.delivered.fan_message.payment_pending.includes(:receiver).group_by { |m| m.receiver_id }
    paid_messages_map.each do |_rid, ms|
      receiver = ms.first.receiver
      msg = "#{ms.size}개의 답장가능한 메시지가 있습니다. 답장하고 수익을 쌓으세요!"
      buttons = [Button.new({type: 'web_url', url: "#{APP_CONFIG[:host_url]}/messages", title: '메시지박스'},)]
      Waikiki::MessageSender.send_button_message(receiver, msg, buttons)
    end
  end

end