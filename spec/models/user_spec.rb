require 'rails_helper'

describe User do

  context 'base methods' do
    it 'can discern partners from normal users' do
      user = FactoryGirl.create(:user)
      partner = FactoryGirl.create(:partner)
      expect(user.is_partner?).to be_falsey
      expect(partner.is_partner?).to be_truthy
    end
  end

  context 'optin actions' do
    it 'should be associated with partner' do
      partner = FactoryGirl.create(:partner_without_messenger)
      user = FactoryGirl.create(:user)
      user.optin(:PTN, partner.id)
      expect(partner.reload.messenger_id).to eq(user.messenger_id)
      expect(partner.reload.is_partner).to be_truthy
      expect{ User.find(user.id) }.to raise_error(ActiveRecord::RecordNotFound)
    end
    it 'should make message and change status' do
      user = FactoryGirl.create(:user)
      partner = FactoryGirl.create(:partner)
      expect { user.optin(:MSG, partner.id) }.to change(Message, :count).by(1)
      message = Message.first
      expect(user.status).to eq('message_initiated')
      expect(message.status).to eq('initiated')
      expect(user.current_message.id).to eq(message.id)
    end
    it 'should not make message if already has one' do
      user = FactoryGirl.create(:user)
      partner = FactoryGirl.create(:partner)
      user.optin(:MSG, partner.id)
      expect { user.optin(:MSG, partner.id) }.not_to change(Message, :count)
      expect(user.current_message.id).to eq(Message.first.id)
    end
    it 'should make reply message' do
      user = FactoryGirl.create(:partner)
      message = FactoryGirl.create(:message, receiver: user, status: :delivered)
      FactoryGirl.create(:payment, message: message, status: :pay_success)
      expect { user.optin(:RPL, message.id) }.to change(Message, :count).by(1)
      expect(user.status).to eq('reply_initiated')
      expect(user.current_message.initial_message.id).to eq(message.id)
    end
    it 'should not make reply message if already has one' do
      user = FactoryGirl.create(:partner)
      message = FactoryGirl.create(:message, receiver: user, status: :delivered)
      user.optin(:RPL, message.id)
      expect { user.optin(:RPL, message.id) }.not_to change(Message, :count)
    end
  end

  context 'postback actions' do
    context 'fan side' do
      it 'can go to nickname setting' do
        user = FactoryGirl.create(:user, status: :message_initiated)
        FactoryGirl.create(:message, sender: user)
        user.start_setting_nickname!
        expect(user.status).to eq('nickname_setting')
      end
      it 'can go to messaging' do
        user = FactoryGirl.create(:user, status: :message_initiated)
        FactoryGirl.create(:message, sender: user)
        user.start_messaging!
        expect(user.status).to eq('messaging')
      end
      it 'can go to message confirm' do
        user = FactoryGirl.create(:user, status: :messaging)
        FactoryGirl.create(:message, sender: user)
        user.confirm_message!
        expect(user.status).to eq('message_confirm')
      end
      it 'can go to message completed' do
        user = FactoryGirl.create(:user, status: :message_confirm)
        FactoryGirl.create(:message, sender: user)
        user.complete_message!
        expect(user.status).to eq('message_completed')
        expect(user.current_message.status).to eq('completed')
      end
      it 'can go back from message confirm' do
        user = FactoryGirl.create(:user, status: :message_confirm)
        message = FactoryGirl.create(:message, sender: user)
        user.cancel_message!
        expect(user.status).to eq('waiting')
        expect(user.current_message).to be_nil
        expect(message.reload.status).to eq('cancelled')
      end
      it 'can be finished after message completed' do
        user = FactoryGirl.create(:user, status: :message_completed)
        message = FactoryGirl.create(:message, sender: user, status: :completed)
        user.reject_payment!
        expect(user.status).to eq('waiting')
        expect(user.current_message).to be_nil
        expect(message.reload.status).to eq('delivered')
      end
      it 'can initiate payment' do
        user = FactoryGirl.create(:user, status: :message_completed)
        FactoryGirl.create(:message, sender: user, status: :completed)
        expect { user.initiate_payment! }.to change(Payment, :count).by(1)
        expect(user.status).to eq('payment_initiated')
        expect(user.current_message.payment.id).to eq(Payment.first.id)
        expect(user.current_message.payment.status).to eq('pay_request')
        expect(user.current_message.payment.pay_amount).to eq(user.current_message.receiver.price)
      end
      it 'can go back from payment initiated' do
        user = FactoryGirl.create(:user, status: :payment_initiated)
        message = FactoryGirl.create(:message, sender: user, status: :completed)
        payment = FactoryGirl.create(:payment, message: message, status: :pay_request)
        user.cancel_payment!
        expect(user.status).to eq('waiting')
        expect(user.current_message).to be_nil
        expect(message.reload.status).to eq('delivered')
        expect(payment.reload.status).to eq('wasted')
      end
      it 'can be finished after payment completed' do
        user = FactoryGirl.create(:user, status: :payment_initiated)
        message = FactoryGirl.create(:message, sender: user, status: :completed)
        payment = FactoryGirl.create(:payment, message: message, status: :pay_request)
        payment.succeed_pay!
        expect(user.reload.status).to eq('waiting')
        expect(user.current_message).to be_nil
        expect(message.reload.status).to eq('delivered')
        expect(payment.reload.status).to eq('pay_success')
      end
      it 'can start messaging in reply of a message' do
        user = FactoryGirl.create(:user)
        message = FactoryGirl.create(:reply_message, receiver: user, status: :delivered)
        expect { user.reply_to(message.id) }.to change(Message, :count).by(1)
        expect(user.status).to eq('messaging')
        expect(user.current_message.status).to eq('initiated')
        expect(user.current_message.initial_message.id).to eq(message.id)
      end
    end
    context 'partner side' do
      it 'can go to replying' do
        user = FactoryGirl.create(:partner, status: :reply_initiated)
        FactoryGirl.create(:reply_message, sender: user)
        user.start_replying!
        expect(user.status).to eq('replying')
      end
      it 'can go to reply confirm' do
        user = FactoryGirl.create(:partner, status: :replying)
        FactoryGirl.create(:reply_message, sender: user)
        user.confirm_reply!
        expect(user.status).to eq('reply_confirm')
      end
      it 'can be finished after reply complete' do
        user = FactoryGirl.create(:user)
        partner = FactoryGirl.create(:partner, status: :reply_confirm)
        message = FactoryGirl.create(:message, sender: user, receiver: partner, status: :delivered)
        payment = FactoryGirl.create(:payment, message: message, status: :pay_success)
        reply_message = FactoryGirl.create(:reply_message, sender: partner, receiver: user, initial_message: message)

        partner.complete_reply!

        expect(partner.status).to eq('waiting')
        expect(partner.current_message).to be_nil
        expect(partner.reload.balance).to eq(payment.partner_share)
        expect(reply_message.reload.status).to eq('delivered')
      end
      it 'can go back from reply confirm' do
        user = FactoryGirl.create(:partner, status: :reply_confirm)
        message = FactoryGirl.create(:reply_message, sender: user)
        user.cancel_reply!
        expect(user.status).to eq('waiting')
        expect(user.current_message).to be_nil
        expect(message.reload.status).to eq('cancelled')
      end
    end
  end

  context 'text actions' do
    it 'can set nickname' do
      user = FactoryGirl.create(:user, status: :nickname_setting)
      FactoryGirl.create(:message, sender: user, status: :initiated)
      name = 'new name'
      user.text_message(name)
      expect(user.status).to eq('messaging')
      expect(user.name).to eq(name)
    end
    it 'can write message' do
      user = FactoryGirl.create(:user, status: :messaging)
      message = FactoryGirl.create(:message, sender: user, status: :initiated)
      content = 'hello world'
      user.text_message(content)
      expect(user.status).to eq('message_confirm')
      expect(message.reload.text).to eq(content)
    end
  end

  context 'video actions' do
    it 'can set video url' do
      user = FactoryGirl.create(:partner, status: :replying)
      message = FactoryGirl.create(:reply_message, sender: user)
      url = 'video url'
      user.video_message(url)
      expect(user.status).to eq('reply_confirm')
      expect(message.reload.video_url).to eq(url)
    end
  end

end