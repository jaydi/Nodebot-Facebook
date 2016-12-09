namespace :payments do
  desc '오래된 결제들 버림'
  task :waste => :environment do
    Payment.timed_outs.each do |p|
      p.waste!
    end
  end

  private

  def my_logger
    @my_logger ||= ::Logger.new("#{Rails.root}/log/#{Rails.env}_payments_task.log")
  end
end