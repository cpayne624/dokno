require_relative 'config/config'

module Dokno
  class Engine < ::Rails::Engine
    isolate_namespace Dokno
  end
end
