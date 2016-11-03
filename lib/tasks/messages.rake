namespace :messages do
  desc '하루 이상 지난 메시지들 버림'
  task :waste => :environment do
    Message.timed_outs.each do |m|
      m.waste!
    end
  end

  private

  def my_logger
    @my_logger ||= ::Logger.new("#{Rails.root}/log/#{Rails.env}_messages_task.log")
  end
end