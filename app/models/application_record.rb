# base for all models (Habit, Checkin, User)
class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class
end
