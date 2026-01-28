class ApplicationJob < ActiveJob::Base
  # optional: retry when we hit a deadlock (https://api.rubyonrails.org/classes/ActiveJob/Exceptions/ClassMethods.html#method-i-retry_on)
  # retry_on ActiveRecord::Deadlocked

  # optional: discard when the record's gone so we dont keep retrying
  # discard_on ActiveJob::DeserializationError
end
