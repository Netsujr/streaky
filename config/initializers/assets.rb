# be sure to restart the servert when you change this file

# bump this if you want to expire all assets (https://guides.rubyonrails.org/asset_pipeline.html)
Rails.application.config.assets.version = "1.0"

# add more paths here if needed
# Rails.application.config.assets.paths << Emoji.images_path

# precompile tailwind build output so rails serves it in prod
Rails.application.config.assets.precompile += %w( tailwind.css )
