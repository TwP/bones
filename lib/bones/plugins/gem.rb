
module Bones::Plugins::Gem
  extend self

  def initialize_gem
    config
    ::Bones.import 'gem.rake'
  end

  def config
    ::Bones.config {
      gem {
        dependencies  Array.new

        development_dependencies  Array.new

        executables  nil

        extensions  FileList['ext/**/extconf.rb']

        files  nil

        need_tar  true

        need_zip  false

        extras  Hash.new
      }
    }
  end

end  # Bones::Plugins::Gem

# EOF
