module MessengerHelper

  def send_text(msg)
    Waikiki::MessageSender.send_text_message(self, msg)
  end

  def send_quick_replies(msg, quick_replies: [])
    Waikiki::MessageSender.send_quick_reply_message(self, msg, quick_replies.map { |qr| QuickReply.new(qr) })
  end

  def send_buttons(msg, buttons: [])
    Waikiki::MessageSender.send_button_message(self, msg, buttons.map { |b| Button.new(b) })
  end

  def send_attachment(attachment)
    Waikiki::MessageSender.send_attachment_message(self, Attachment.new(attachment))
  end

end