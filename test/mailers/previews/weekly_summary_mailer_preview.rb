# Preview all emails at http://localhost:3000/rails/mailers/weekly_summary_mailer
class WeeklySummaryMailerPreview < ActionMailer::Preview

  # Preview this email at http://localhost:3000/rails/mailers/weekly_summary_mailer/summary
  def summary
    WeeklySummaryMailer.summary
  end

end
