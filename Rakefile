# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)
require 'rake'

module ::Tapstest
  class Application
    include Rake::DSL
  end
end

Tapstest::Application.load_tasks
