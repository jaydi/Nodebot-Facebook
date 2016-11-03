namespace :payments do
  desc '만료된 결제들과 버림'
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