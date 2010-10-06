source :rubygems

gem 'rails',              '2.3.4'
gem 'rack',               '1.0.1'
gem 'clearance',          '0.8.8'
gem 'jrails',             '0.6.0'

group :development do
  gem 'annotate',       '2.4.0'
  gem 'sqlite3-ruby',   :require => 'sqlite3'
end

group :test do
  if RUBY_VERSION[/1\.8\.7/]
    gem 'minitest',     '1.7.2'
  end
  gem 'factory_girl',   '1.2.4'
  gem 'rcov',           '0.9.9'
  gem 'shoulda',        '2.10.2'
end
