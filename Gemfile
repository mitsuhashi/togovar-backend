# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.2.4'

gem 'rails', '~> 6.1.7'

# middleware
gem 'puma', '~> 5.6'
gem 'rack-cors', '~> 1.1', '>= 1.1.1'
gem 'unicorn', '~> 5.7'

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.4.2', require: false

# frontend
gem 'haml-rails', '~> 2.0'
gem 'jbuilder', '~> 2.5'
gem 'js-routes', '~> 1.4'
gem 'sass-rails', '~> 5.0'

# utility
gem 'active_interaction', '~> 4.1'
gem 'dotenv-rails', '~> 2.7', '>= 2.7.6'
gem 'rails_pretty_json_rednerer', '~> 0.1.0'

# elasticsearch
gem 'elasticsearch-dsl', '~> 0.1.9'
gem 'elasticsearch-model', '~> 7.1'
gem 'elasticsearch-rails', '~> 7.1'

# A collection of Rack middleware to support JSON Schema
gem 'committee', '~> 4.2', '>= 4.2.1'

# A metadistribution of RDF.rb including a full set of parsing/serialization plugins
gem 'linkeddata', '~> 3.0'

# bio science
gem 'bio-vcf', github: 'pjotrp/bioruby-vcf'

# authorization
gem 'omniauth-keycloak', '~> 1.5', '>= 1.5.2'
gem 'omniauth-rails_csrf_protection', '~> 1.0', '>= 1.0.2'
gem 'redis-rails', '~> 5.0', '>= 5.0.2'

# swagger
gem 'rswag-ui'

group :development do
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'foreman'
  gem 'listen', '~> 3.3'
  gem 'rack-rewrite', require: 'rack/rewrite'
  gem "rack-reverse-proxy", require: "rack/reverse_proxy"
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
  gem 'web-console', '~> 4.1'
end

group :development, :test do
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  gem 'rspec-rails', '~> 5.1', '>= 5.1.2'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
# gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]
