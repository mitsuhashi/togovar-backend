# frozen_string_literal: true

Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Do not eager load code on boot.
  config.eager_load = false

  # Show full error reports.
  config.consider_all_requests_local = true

  # Enable/disable caching. By default caching is disabled.
  # Run rails dev:cache to toggle caching.
  if Rails.root.join('tmp', 'caching-dev.txt').exist?
    config.cache_store = :memory_store
    config.public_file_server.headers = {
      'Cache-Control' => "public, max-age=#{2.days.to_i}"
    }
  else
    config.action_controller.perform_caching = false

    config.cache_store = :null_store
  end

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  config.log_formatter = ::Logger::Formatter.new

  logger = ActiveSupport::Logger.new($stdout)
  logger.formatter = config.log_formatter
  config.logger = ActiveSupport::TaggedLogging.new(logger)

  # Raises error for missing translations.
  # config.action_view.raise_on_missing_translations = true

  # Use an evented file watcher to asynchronously detect changes in source code,
  # routes, locales, etc. This feature depends on the listen gem.
  config.file_watcher = ActiveSupport::EventedFileUpdateChecker

  config.middleware.insert(0, Rack::ReverseProxy) do
    reverse_proxy_options preserve_host: true
    reverse_proxy '/togovar/GRCh38/', 'https://togovar.github.io'
  end

  config.middleware.insert(0, Rack::Rewrite) do
    rewrite %r{^/(index.html)?$}, '/togovar/GRCh38/index.html'
    rewrite %r{^/(css|fonts|images|js)/(.*)$}, '/togovar/GRCh38/$1/$2'
    rewrite %r{^/(variant)/tgv\d+$}, '/togovar/GRCh38/$1/index.html'
    rewrite %r{^/(disease)/\d+$}, '/togovar/GRCh38/$1/index.html'
    rewrite %r{^/(gene)/CN?\d+$}, '/togovar/GRCh38/$1/index.html'
  end
end
