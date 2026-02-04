# base for background jobs (reminder, weekly summary). good_job runs these. optional retry/discard commented below if we need them.
class ApplicationJob < ActiveJob::Base
  # retry_on ActiveRecord::Deadlocked
  # discard_on ActiveJob::DeserializationError
end
