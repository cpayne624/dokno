module Dokno
  module Generators
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path('../../templates', __FILE__)

      desc 'Copies the Dokno configuration templates to the host app'
      def copy_initializer
        template 'config/initializers/dokno.rb', 'config/initializers/dokno.rb'
        template 'config/dokno_template.md', 'config/dokno_template.md'
      end
    end
  end
end
