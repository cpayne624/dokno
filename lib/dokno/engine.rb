require_relative 'config/config'

module Dokno
  class Engine < ::Rails::Engine
    isolate_namespace Dokno

    initializer :append_migrations do |app|
      config.paths["db/migrate"].expanded.each do |expanded_path|
        app.config.paths["db/migrate"] << expanded_path
      end
    end
  end
end
