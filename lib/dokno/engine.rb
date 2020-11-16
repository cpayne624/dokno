require_relative 'config/config'

module Dokno
  class Engine < ::Rails::Engine
    isolate_namespace Dokno

    initializer :append_migrations do |app|
      config.paths["db/migrate"].expanded.each do |expanded_path|
        app.config.paths["db/migrate"] << expanded_path
      end
    end

    initializer 'local_helper.action_controller' do
      ActiveSupport.on_load :action_controller do
        helper Dokno::ApplicationHelper
      end
    end
  end
end
