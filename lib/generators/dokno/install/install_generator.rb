module Dokno
  module Generators
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path('../../templates', __FILE__)

      desc 'Copys the Dokno template initializer to the host application'
      def copy_initializer
        template 'config/initializers/dokno.rb', 'config/initializers/dokno.rb'
      end
    end
  end
end