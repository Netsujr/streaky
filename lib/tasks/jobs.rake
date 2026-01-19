namespace :jobs do
  desc "Run reminder job manually"
  task reminder: :environment do
    puts "Running ReminderJob..."
    ReminderJob.perform_now
    puts "ReminderJob completed!"
  end

  desc "Run weekly summary job manually"
  task weekly_summary: :environment do
    puts "Running WeeklySummaryJob..."
    WeeklySummaryJob.perform_now
    puts "WeeklySummaryJob completed!"
  end
end
