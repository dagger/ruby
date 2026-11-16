require_relative "boot"

require "rails"
require "active_record/railtie"
require "rails/test_unit/railtie"

Bundler.require(*Rails.groups)

module App
  class Application < Rails::Application
    config.eager_load = false
  end
end
