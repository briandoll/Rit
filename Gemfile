source 'http://rubygems.org'

gem 'rails', '3.0.0'
gem 'sqlite3-ruby', :require => 'sqlite3'

gem 'clearance', :git => 'git://github.com/thoughtbot/clearance.git'
gem 'jrails', '0.6.0'

# TODO RAILS3 - rails s gives `build_mem_cache': uninitialized constant ActiveSupport::Cache::MemCacheStore::MemCache
# gem 'memcache', '1.2.3'

group :development do
  gem 'annotate', '2.4.0'
end

group :test do
  gem 'factory_girl_rails', '1.0'
  gem 'shoulda', '2.11.3'
end

group :test, :development do
  gem "rspec-rails", ">= 2.0.0.beta.20"
end
