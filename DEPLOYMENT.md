# Deployment Guide

This guide covers deploying Streaky to various hosting platforms.

## Table of Contents

- [Prerequisites](#prerequisites)
- [Heroku Deployment](#heroku-deployment)
- [Railway Deployment](#railway-deployment)
- [Render Deployment](#render-deployment)
- [Fly.io Deployment](#flyio-deployment)
- [Post-Deployment Setup](#post-deployment-setup)
- [Environment Variables](#environment-variables)
- [Troubleshooting](#troubleshooting)

## Prerequisites

Before deploying, ensure you have:

- A Git repository with your code
- A PostgreSQL database (provided by most hosting platforms)
- Ruby 3.1.2 or higher
- Node.js (for asset compilation)

## Heroku Deployment

### 1. Install Heroku CLI

```bash
# macOS
brew tap heroku/brew && brew install heroku

# Or download from https://devcenter.heroku.com/articles/heroku-cli
```

### 2. Login and Create App

```bash
heroku login
heroku create your-app-name
```

### 3. Add PostgreSQL Addon

```bash
heroku addons:create heroku-postgresql:mini
```

### 4. Set Environment Variables

```bash
# Set Rails master key (required for encrypted credentials)
heroku config:set RAILS_MASTER_KEY=$(cat config/master.key)

# Set mailer from address (required for emails)
heroku config:set MAILER_FROM=noreply@yourdomain.com

# Optional: Set app URL for email links
heroku config:set APP_URL=https://your-app-name.herokuapp.com
```

### 5. Deploy

```bash
git push heroku main
# Or if using master branch:
git push heroku master
```

### 6. Run Migrations and Seed

```bash
heroku run rails db:migrate
heroku run rails db:seed
```

### 7. Start Worker Dyno (Required for Background Jobs)

```bash
heroku ps:scale worker=1
```

### 8. Set Up Scheduled Jobs

Install Heroku Scheduler addon:

```bash
heroku addons:create scheduler:standard
```

Then add scheduled jobs via the Heroku dashboard:

1. Go to your app → Add-ons → Heroku Scheduler
2. Add a new job:
   - **Daily Reminder**: `rails jobs:reminder` (run daily at 09:00 UTC)
   - **Weekly Summary**: `rails jobs:weekly_summary` (run weekly on Monday at 08:00 UTC)

### 9. Verify Deployment

```bash
heroku open
```

## Railway Deployment

### 1. Install Railway CLI

```bash
npm i -g @railway/cli
```

### 2. Login and Initialize

```bash
railway login
railway init
```

### 3. Create PostgreSQL Service

1. Go to Railway dashboard
2. Click "New Project"
3. Add a PostgreSQL service
4. Add a Web Service and connect your GitHub repository

### 4. Set Environment Variables

In Railway dashboard, add these variables:

```
RAILS_MASTER_KEY=<your-master-key>
MAILER_FROM=noreply@yourdomain.com
RAILS_ENV=production
```

### 5. Configure Build and Start Commands

In Railway, set:

- **Build Command**: `bundle install && rails assets:precompile`
- **Start Command**: `rails server -b 0.0.0.0 -p $PORT`

### 6. Run Migrations

In Railway dashboard, open the web service shell and run:

```bash
rails db:migrate
rails db:seed
```

### 7. Set Up Background Jobs

Railway supports background workers. Create a new service with:

- **Start Command**: `bundle exec good_job start`

### 8. Set Up Scheduled Jobs

Use Railway's Cron Jobs feature or a separate service with `whenever` gem.

## Render Deployment

### 1. Create Account and Connect Repository

1. Go to [render.com](https://render.com)
2. Connect your GitHub/GitLab repository

### 2. Create PostgreSQL Database

1. Click "New +" → "PostgreSQL"
2. Choose a name and region
3. Note the connection string

### 3. Create Web Service

1. Click "New +" → "Web Service"
2. Connect your repository
3. Configure:
   - **Name**: Your app name
   - **Environment**: Ruby
   - **Build Command**: `bundle install && rails assets:precompile`
   - **Start Command**: `bundle exec puma -C config/puma.rb`

### 4. Set Environment Variables

In the Web Service settings, add:

```
RAILS_MASTER_KEY=<your-master-key>
DATABASE_URL=<from-postgres-service>
MAILER_FROM=noreply@yourdomain.com
RAILS_ENV=production
```

### 5. Create Background Worker

1. Click "New +" → "Background Worker"
2. Use the same repository
3. Set **Start Command**: `bundle exec good_job start`

### 6. Run Migrations

In the Web Service shell:

```bash
rails db:migrate
rails db:seed
```

### 7. Set Up Scheduled Jobs

Use Render's Cron Jobs or a separate worker with `whenever` gem.

## Fly.io Deployment

### 1. Install Fly CLI

```bash
# macOS
brew install flyctl

# Or download from https://fly.io/docs/getting-started/installing-flyctl/
```

### 2. Login and Initialize

```bash
flyctl auth login
flyctl launch
```

### 3. Create PostgreSQL Database

```bash
flyctl postgres create --name your-app-db
flyctl postgres attach your-app-db
```

### 4. Set Secrets

```bash
flyctl secrets set RAILS_MASTER_KEY=$(cat config/master.key)
flyctl secrets set MAILER_FROM=noreply@yourdomain.com
```

### 5. Deploy

```bash
flyctl deploy
```

### 6. Run Migrations

```bash
flyctl ssh console
rails db:migrate
rails db:seed
```

### 7. Set Up Background Jobs

Add a separate process in `fly.toml`:

```toml
[[processes]]
  name = "worker"
  command = "bundle exec good_job start"
```

## Post-Deployment Setup

### 1. Verify Database Connection

```bash
# On Heroku
heroku run rails console

# On Railway/Render
# Use the web console or SSH
```

### 2. Test Email Delivery

Configure your email service (SendGrid, Mailgun, Postmark, etc.):

```bash
# Example with SendGrid
heroku config:set SENDGRID_USERNAME=your_username
heroku config:set SENDGRID_PASSWORD=your_password
```

Update `config/environments/production.rb`:

```ruby
config.action_mailer.smtp_settings = {
  address: 'smtp.sendgrid.net',
  port: 587,
  domain: 'yourdomain.com',
  user_name: ENV['SENDGRID_USERNAME'],
  password: ENV['SENDGRID_PASSWORD'],
  authentication: :plain,
  enable_starttls_auto: true
}
```

### 3. Set Up Custom Domain (Optional)

#### Heroku

```bash
heroku domains:add www.yourdomain.com
heroku domains:add yourdomain.com
```

Then configure DNS with your domain provider.

#### Railway/Render

Add custom domain in the dashboard and configure DNS.

### 4. Enable SSL/HTTPS

Most platforms provide SSL automatically. For custom domains:

- **Heroku**: Automatic with paid dynos
- **Railway**: Automatic
- **Render**: Automatic
- **Fly.io**: Automatic with Let's Encrypt

## Environment Variables

### Required Variables

- `RAILS_MASTER_KEY`: Master key for encrypted credentials (found in `config/master.key`)
- `RAILS_ENV`: Set to `production`
- `DATABASE_URL`: Usually provided automatically by hosting platform

### Optional Variables

- `MAILER_FROM`: Email address for sending emails (default: `noreply@streaky.app`)
- `APP_URL`: Base URL of your application (for email links)
- `SENDGRID_USERNAME`: If using SendGrid for email
- `SENDGRID_PASSWORD`: If using SendGrid for email

## Troubleshooting

### Database Connection Issues

```bash
# Check database URL
heroku config:get DATABASE_URL

# Test connection
heroku run rails db:version
```

### Asset Compilation Errors

```bash
# Precompile assets locally and commit
rails assets:precompile
git add public/assets
git commit -m "Add precompiled assets"
git push heroku main
```

### Background Jobs Not Running

1. Verify worker dyno is running:
   ```bash
   heroku ps
   ```

2. Check Good Job logs:
   ```bash
   heroku logs --tail --ps worker
   ```

### Email Not Sending

1. Check email configuration in `config/environments/production.rb`
2. Verify SMTP credentials are set
3. Check mailer logs:
   ```bash
   heroku logs --tail | grep mailer
   ```

### Performance Issues

1. Enable Rails caching:
   ```bash
   heroku config:set RAILS_SERVE_STATIC_FILES=true
   ```

2. Use CDN for assets (CloudFront, Cloudflare, etc.)

3. Monitor with platform's built-in tools or New Relic/DataDog

### Common Errors

**"We're sorry, but something went wrong"**

- Check logs: `heroku logs --tail`
- Verify `RAILS_MASTER_KEY` is set
- Check database migrations ran successfully

**"No such file or directory - node"**

- Ensure Node.js buildpack is added:
  ```bash
  heroku buildpacks:add heroku/nodejs
  heroku buildpacks:add heroku/ruby
  ```

**"PG::ConnectionBad: could not connect to server"**

- Verify PostgreSQL addon is provisioned
- Check `DATABASE_URL` is set correctly

## Monitoring and Maintenance

### View Logs

```bash
# Heroku
heroku logs --tail

# Railway
railway logs

# Render
# View in dashboard

# Fly.io
flyctl logs
```

### Run Console

```bash
# Heroku
heroku run rails console

# Railway
railway run rails console

# Render
# Use web console

# Fly.io
flyctl ssh console
rails console
```

### Backup Database

```bash
# Heroku
heroku pg:backups:capture
heroku pg:backups:download

# Railway/Render
# Use platform's backup feature

# Fly.io
flyctl postgres backup create
```

## Security Checklist

- [ ] Set `RAILS_ENV=production`
- [ ] Use strong `RAILS_MASTER_KEY` (never commit to Git)
- [ ] Enable HTTPS/SSL
- [ ] Set secure session cookies
- [ ] Use environment variables for secrets
- [ ] Regularly update dependencies
- [ ] Enable database backups
- [ ] Set up monitoring and alerts
- [ ] Review and restrict database access
- [ ] Use strong passwords for admin accounts

## Additional Resources

- [Rails Deployment Guide](https://guides.rubyonrails.org/deployment.html)
- [Heroku Ruby Support](https://devcenter.heroku.com/articles/ruby-support)
- [Good Job Documentation](https://github.com/bensheldon/good_job)
- [Action Mailer Configuration](https://guides.rubyonrails.org/action_mailer_basics.html)
