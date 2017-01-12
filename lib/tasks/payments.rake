namespace :payments do
  desc '오래된 결제들 버림'
  task :waste => :environment do
    Payment.timed_outs.each do |p|
      p.waste!
    end
  end
end