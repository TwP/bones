
require 'rake/rdoctask'

module Bones::Plugins::Rdoc
  include ::Bones::Helpers
  extend self

  def initialize_rdoc
    ::Bones.config { 
      rdoc {
        opts  []
        include  %w(^lib/ ^bin/ ^ext/ \.txt$ \.rdoc$)
        exclude  %w(extconf\.rb$)
        main  nil
        dir  'doc'
        remote_dir  nil
      }
    }
  end

  def post_load
    config = ::Bones.config

    config.exclude << "^#{Regexp.escape(config.rdoc.dir)}/"
    config.rdoc.main ||= config.readme_file
  end

  def define_tasks
    config = ::Bones.config

    namespace :doc do
      desc 'Generate RDoc documentation'
      Rake::RDocTask.new do |rd|
        rdoc = config.rdoc
        rd.main = rdoc.main
        rd.rdoc_dir = rdoc.dir

        incl = Regexp.new(rdoc.include.join('|'))
        excl = Regexp.new(rdoc.exclude.join('|'))
        files = config.gem.files.find_all do |fn|
                  case fn
                  when excl; false
                  when incl; true
                  else false end
                end
        rd.rdoc_files.push(*files)

        title = "#{config.name}-#{config.version} Documentation"

        rd.options << "-t #{title}"
        rd.options.concat(rdoc.opts)
      end

      desc 'Generate ri locally for testing'
      task :ri => :clobber_ri do
        sh "#{RDOC} --ri -o ri ."
      end

      task :clobber_ri do
        rm_r 'ri' rescue nil
      end
    end  # namespace :doc

    desc 'Alias to doc:rdoc'
    task :doc => 'doc:rdoc'

    desc 'Remove all build products'
    task :clobber => %w(doc:clobber_rdoc doc:clobber_ri)

    remove_desc_for_task %w(doc:clobber_rdoc)
  end

end  # module Bones::Plugins::Rdoc

# EOF
