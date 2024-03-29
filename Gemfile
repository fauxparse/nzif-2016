source 'https://rubygems.org'
ruby '2.4.1'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 5.1.2'
# Use postgresql as the database for Active Record
gem 'pg', '~> 0.18'
# Use Puma as the app server
gem 'puma', '~> 3.0'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails'
# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

gem 'rspec-rails', '3.5.0.beta4'
gem 'haml', '~> 5.0.1'
gem 'haml-rails', github: 'indirect/haml-rails'
gem 'bourbon', '>= 5.0.0.beta.5'
gem 'neat', '~> 1.8.0'
gem 'autoprefixer-rails'
gem 'inline_svg'
gem 'mithril_rails', github: 'fauxparse/mithril-rails'

gem 'stringex'
gem 'acts_as_list', github: 'swanandp/acts_as_list'
gem 'active_model_serializers', '~> 0.10.0'
gem 'geocoder'
gem 'cry'
gem 'money-rails'

gem 'paperclip', github: 'thoughtbot/paperclip'
gem 'aws-sdk'

gem 'icalendar'
gem 'pleasant-lawyer'

gem 'wicked_pdf', github: 'mileszs/wicked_pdf'
gem 'wkhtmltopdf-binary'

gem 'nokogiri'
gem 'premailer-rails'

gem 'redcarpet'

# Use jquery as the JavaScript library
gem 'jquery-rails'
# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
gem 'turbolinks', '~> 5.x'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.0'
# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 3.0'
# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

gem 'devise', '~> 4.1'
gem 'pundit'
gem 'figaro'

gem 'unicorn'

gem 'google-analytics-rails'
gem 'google-analytics-turbolinks'

gem 'rollbar'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platform: :mri
  gem 'cucumber-rails', :require => false
  gem 'spring-commands-rspec'
  gem 'spring-commands-cucumber'
  gem 'factory_girl_rails', '~> 4.0'
  gem 'rspec-collection_matchers'
  gem 'timecop'
  gem 'sinon-rails'

  gem 'rspec', '= 3.5.0.beta4'
  gem 'rspec-core', '= 3.5.0.beta4'
  gem 'rspec-expectations', '= 3.5.0.beta4'
  gem 'rspec-mocks', '= 3.5.0.beta4'
  gem 'rspec-support', '= 3.5.0.beta4'
  gem 'pry-rails'
  gem 'poltergeist'
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> anywhere in the code.
  gem 'web-console'
  gem 'listen', '~> 3.0.5'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
  gem 'guard'
  gem 'guard-rspec', '>= 4.7.2'
  gem 'guard-cucumber'
  gem 'guard-rails', require: false
  gem 'letter_opener_web'
  gem 'rails_real_favicon'
end

group :test do
  gem 'codeclimate-test-reporter', require: nil
  gem 'database_cleaner'
  gem 'shoulda-matchers', '~> 3.1'
  gem 'email_spec'
end

group :production do
  gem 'rails_12factor'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
