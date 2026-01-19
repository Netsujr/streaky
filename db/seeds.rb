user = User.find_or_create_by!(email: "demo@streaky.app") do |u|
  u.name = "Demo User"
  u.password = "password123"
  u.password_confirmation = "password123"
  u.timezone = "America/Sao_Paulo"
  u.weekly_summary_enabled = true
  u.reminders_enabled = true
end

today = Time.use_zone(user.timezone) { Time.zone.today }

habit1 = user.habits.find_or_create_by!(name: "Daily Exercise") do |h|
  h.goal_per_week = 7
  h.start_date = today - 30.days
  h.color = "blue"
end

habit2 = user.habits.find_or_create_by!(name: "Read for 30 minutes") do |h|
  h.goal_per_week = 5
  h.start_date = today - 20.days
  h.color = "green"
end

habit3 = user.habits.find_or_create_by!(name: "Meditate") do |h|
  h.goal_per_week = 7
  h.start_date = today - 14.days
  h.color = "purple"
end

(0..13).each do |i|
  date = today - i.days

  if i % 2 == 0
    Checkin.find_or_create_by!(habit: habit1, user: user, occurred_on: date)
  end

  if i % 3 != 0
    Checkin.find_or_create_by!(habit: habit2, user: user, occurred_on: date)
  end

  Checkin.find_or_create_by!(habit: habit3, user: user, occurred_on: date) if i < 7
end

puts "Seeded database with demo user and habits!"
puts "Email: demo@streaky.app"
puts "Password: password123"
