require 'rails_helper'

describe Celeb do
  let(:celeb) { FactoryGirl.create(:celeb) }
  let(:info_filled_celeb) { FactoryGirl.create(:info_filled_celeb, email: 'other@e.mail') }
  let(:paired_celeb) { FactoryGirl.create(:celeb_user).celeb }

  context 'status changes' do
    it 'should be pending before initiating' do
      expect(celeb.status).to eq('pending')
    end
    it 'should be active after initiating' do
      celeb.initiate!
      expect(celeb.status).to eq('active')
    end
    it 'should be deactivated after deactivating' do
      celeb.initiate!
      celeb.deactivate!
      expect(celeb.status).to eq('deactivated')
    end
  end

  context 'model validation' do
    it 'should not be saved on duplicate email' do
      c1 = Celeb.create(email: 'email', password: 'password')
      c2 = Celeb.new(email: c1.email, password: c1.password)
      expect { c2.save! }.to raise_error(ActiveRecord::RecordInvalid)
    end
  end

end