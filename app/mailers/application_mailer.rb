# base mailer, from address from env (default noreply@streaky.app)
class ApplicationMailer < ActionMailer::Base
  default from: ENV.fetch("MAILER_FROM", "noreply@streaky.app")
  layout "mailer"
end
