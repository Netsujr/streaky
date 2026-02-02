# frozen_string_literal: true

# Idempotent seeds: safe to run multiple times (e.g. in production after deploy).
# 5 test accounts, each with 5–10 habits and check-in history for testing flows.

SEED_PASSWORD = "password123"

SEED_USERS = [
  { email: "demo@streaky.app",     name: "Demo User",   timezone: "America/New_York" },
  { email: "alex@streaky.app",     name: "Alex Rivera",  timezone: "America/Los_Angeles" },
  { email: "sam@streaky.app",      name: "Sam Chen",     timezone: "America/Chicago" },
  { email: "jordan@streaky.app",  name: "Jordan Lee",   timezone: "America/Denver" },
  { email: "casey@streaky.app",   name: "Casey Taylor", timezone: "America/Sao_Paulo" }
].freeze

# Pool of habit definitions: name, goal_per_week, color. We pick up to 10 per user.
HABIT_TEMPLATES = [
  { name: "Daily Exercise",      goal_per_week: 7,  color: "blue" },
  { name: "Read 30 minutes",     goal_per_week: 5,  color: "green" },
  { name: "Meditate",            goal_per_week: 7,  color: "purple" },
  { name: "Drink 8 glasses",     goal_per_week: 7,  color: "indigo" },
  { name: "Sleep by 11pm",       goal_per_week: 7,  color: "pink" },
  { name: "No sugar",            goal_per_week: 5,  color: "red" },
  { name: "Walk 10k steps",      goal_per_week: 5,  color: "orange" },
  { name: "Journal",             goal_per_week: 4,  color: "yellow" },
  { name: "Stretch 10 min",      goal_per_week: 7,  color: "green" },
  { name: "Practice guitar",     goal_per_week: 4,  color: "purple" }
].freeze

def seed_user(attrs)
  User.find_or_create_by!(email: attrs[:email]) do |u|
    u.name = attrs[:name]
    u.password = SEED_PASSWORD
    u.password_confirmation = SEED_PASSWORD
    u.timezone = attrs[:timezone]
    u.weekly_summary_enabled = true
    u.reminders_enabled = true
  end
end

def seed_habits_for_user(user, count: 10)
  today = Time.use_zone(user.timezone) { Time.zone.today }
  templates = HABIT_TEMPLATES.shuffle.take(count)

  templates.map do |t|
    user.habits.find_or_create_by!(name: t[:name]) do |h|
      h.goal_per_week = t[:goal_per_week]
      h.start_date = today - rand(14..60).days
      h.color = t[:color]
    end
  end
end

def seed_checkins_for_habits(user, habits)
  today = Time.use_zone(user.timezone) { Time.zone.today }

  habits.each_with_index do |habit, idx|
    # Vary check-in patterns: some habits with long streaks, some with gaps
    (0..20).each do |i|
      date = today - i.days
      next if date < habit.start_date

      # Different pattern per habit so streaks vary
      case idx % 4
      when 0 then create = (i % 2).zero?                        # every other day
      when 1 then create = i < 14                                # last 14 days straight
      when 2 then create = true                                 # every day in range
      else        create = (i % 3 != 0)                         # most days
      end

      next unless create

      Checkin.find_or_create_by!(habit: habit, user: user, occurred_on: date)
    end
  end
end

puts "Seeding users and habits (idempotent)..."

SEED_USERS.each do |attrs|
  user = seed_user(attrs)
  # First user gets 10 habits; others get 5–10 for variety
  count = user.email == "demo@streaky.app" ? 10 : (5 + rand(6))
  habits = seed_habits_for_user(user, count: count)
  seed_checkins_for_habits(user, habits)
  puts "  #{user.email} — #{user.habits.count} habits, #{user.checkins.count} check-ins"
end

puts "Done. Seed accounts (password: #{SEED_PASSWORD}):"
SEED_USERS.each { |u| puts "  #{u[:email]} — #{u[:name]}" }
