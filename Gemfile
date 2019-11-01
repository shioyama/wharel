source "https://rubygems.org"

git_source(:github) {|repo_name| "https://github.com/#{repo_name}" }

# Specify your gem's dependencies in wharel.gemspec
gemspec

gem 'pry-byebug'

case (ENV['RAILS_VERSION'] || '6.0')
when '5.2'
  gem 'activerecord', '~> 5.2'
  gem 'sqlite3', '~> 1.3.13'
when '6.0'
  gem 'activerecord', '~> 6.0'
else
  raise ArgumentError, 'invalid Rails version'
end
