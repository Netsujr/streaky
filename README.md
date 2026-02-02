# Streaky - Habit Tracker

A production-quality Ruby on Rails habit tracker app showcasing Rails + Hotwire (Turbo/Stimulus), Postgres modeling, background jobs, tests, and deploy readiness.

## Features

- **User Authentication**: Simple sign up/login with Rails built-in password authentication
- **Habit Management**: Create, edit, archive habits with customizable goals
- **Daily Check-ins**: Toggle check-ins for today and the last 6 days
- **Streak Tracking**: Calculate current and longest streaks with timezone-aware logic
- **Real-time Updates**: Turbo Streams for instant UI updates without page reloads
- **Hold to Confirm**: Stimulus controller with progress ring for check-in confirmation
- **Background Jobs**: Daily reminders and weekly summaries via Good Job
- **Email Notifications**: Reminders and weekly summaries via Action Mailer

## Tech Stack

- **Ruby**: 3.1.2+
- **Rails**: 7.0.10
- **Database**: PostgreSQL
- **Frontend**: Hotwire (Turbo + Stimulus), Tailwind CSS
- **Background Jobs**: Good Job (Postgres-backed)
- **Email**: Action Mailer with Letter Opener (development)

## Local Setup

1. **Prerequisites**:
   - Ruby 3.1.2 or higher
   - PostgreSQL
   - Node.js (for asset compilation)

2. **Install dependencies**:
   ```bash
   bundle install
   ```

3. **Set up database**:
   ```bash
   rails db:create
   rails db:migrate
   rails db:seed
   ```

   **Seeds** create 5 test accounts, each with 5–10 habits and check-in history so you can test dashboard, streaks, archive, and Turbo Streams. All accounts use the same password: `password123`. Seeds are idempotent (safe to run again).

   | Email | Name | Habits |
   |-------|------|--------|
   | `demo@streaky.app` | Demo User | 10 |
   | `alex@streaky.app` | Alex Rivera | 5–10 |
   | `sam@streaky.app` | Sam Chen | 5–10 |
   | `jordan@streaky.app` | Jordan Lee | 5–10 |
   | `casey@streaky.app` | Casey Taylor | 5–10 |

   To re-run seeds (e.g. after resetting the DB): `rails db:seed`

4. **Start the server**:
   ```bash
   rails server
   ```

   Or use Foreman to run all processes:
   ```bash
   bin/dev
   ```

5. **Access the app**:
   - Visit http://localhost:3000
   - Sign in with any seed account (password for all: `password123`):
     - `demo@streaky.app` (10 habits, good for testing full dashboard)
     - `alex@streaky.app`, `sam@streaky.app`, `jordan@streaky.app`, `casey@streaky.app`

## Running Jobs Locally

Good Job is configured to run in development. To start the worker process:

```bash
bin/good_job start
```

Or use Foreman which will start both the web server and worker:
```bash
bin/dev
```

### Manual Job Execution

For testing purposes, you can run jobs manually:

```bash
# Run reminder job
rails jobs:reminder

# Run weekly summary job
rails jobs:weekly_summary
```

## Deployment (Heroku)

1. **Create Heroku app**:
   ```bash
   heroku create your-app-name
   ```

2. **Set up Postgres**:
   ```bash
   heroku addons:create heroku-postgresql:mini
   ```

3. **Set environment variables** (if needed):
   ```bash
   heroku config:set RAILS_MASTER_KEY=$(cat config/master.key)
   heroku config:set MAILER_FROM=noreply@yourdomain.com
   ```

4. **Deploy**:
   ```bash
   git push heroku main
   ```

5. **Migrations and seeds in production**
   The `Procfile` includes a **release** phase that runs `db:migrate` and `db:seed` on each deploy (Heroku and other platforms that support release commands). So seed data is loaded automatically when you deploy.
   Seeds are **idempotent**: running them again won’t duplicate users (same emails) or habits (same name per user).
   To run migrations and seeds manually instead (e.g. if your host doesn’t use the release phase):
   ```bash
   heroku run rails db:migrate
   heroku run rails db:seed
   ```
   **Render**: In your Web Service, set **Release Command** to: `rails db:migrate && rails db:seed` so migrations and seeds run on every deploy.

6. **Start worker dyno** (required for background jobs):
   ```bash
   heroku ps:scale worker=1
   ```

7. **Set up scheduler** (for scheduled jobs):

   Install Heroku Scheduler addon:
   ```bash
   heroku addons:create scheduler:standard
   ```

   Add scheduled jobs:
   - Daily reminder: `rails jobs:reminder` (run daily, e.g., 09:00 UTC)
   - Weekly summary: `rails jobs:weekly_summary` (run weekly on Monday, e.g., 08:00 UTC)

   Or use a cron job library like `whenever` gem and configure in `config/schedule.rb`.

## 60-Second Demo Script

1. **Sign In**:
   - Go to http://localhost:3000
   - Click "Sign In"
   - Use demo credentials: `demo@streaky.app` / `password123`

2. **View Dashboard**:
   - See pre-seeded habits (demo@streaky.app has 10) with streak stats
   - View 7-day grid for each habit

3. **Toggle Check-in**:
   - Hold any date button in the 7-day grid for ~500ms
   - Watch the progress ring fill up
   - Release to confirm
   - Notice the streak number updates **without page reload** (Turbo Stream)

4. **Create New Habit**:
   - Click "New Habit"
   - Enter name (notice inline validation if > 60 chars)
   - Set goal per week
   - Choose color
   - Submit
   - New habit card appears on dashboard

5. **Check Email**:
   - Run `rails jobs:reminder` in another terminal
   - Check Letter Opener for reminder emails
   - Run `rails jobs:weekly_summary` for weekly summary

6. **View Settings**:
   - Click "Settings" in navigation
   - Change timezone
   - Toggle weekly summary/reminders
   - Save

## Testing

Run the test suite:

```bash
rails test
```

Run specific test files:

```bash
rails test test/services/streak_calculator_test.rb
rails test test/models/checkin_test.rb
rails test test/system/habits_test.rb
```

## Project Structure

- `app/services/streak_calculator.rb`: Timezone-aware streak calculation logic
- `app/queries/habits_dashboard_query.rb`: Efficient dashboard data loading
- `app/jobs/`: Background jobs (ReminderJob, WeeklySummaryJob)
- `app/mailers/`: Email templates (ReminderMailer, WeeklySummaryMailer)
- `app/javascript/controllers/`: Stimulus controllers (hold-confirm, habit-form)
- `test/`: Unit and system tests

## Key Implementation Details

- **Timezone Awareness**: All date calculations use user timezone via `Time.use_zone`
- **Turbo Streams**: Check-in toggles broadcast updates to dashboard and habit cards
- **Hold to Confirm**: SVG progress ring with 500ms hold duration
- **Concurrency Safe**: Checkin unique constraint prevents duplicate check-ins
- **Efficient Queries**: Dashboard query preloads all data in 2 queries (habits + checkins)
- **Background Jobs**: Good Job runs jobs directly from Postgres (no Redis required)

## License

MIT
