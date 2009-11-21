
require 'rake/rdoctask'

module Bones::Plugins::Rdoc
  include ::Bones::Helpers
  extend self

  def initialize_rdoc
    ::Bones.config {
      desc 'Configuration settings for rdoc and ri'
      rdoc {

        opts  [], :desc => 'Array of rdoc options to use when generating documentation.'

        include  %w(^lib/ ^bin/ ^ext/ \.txt$ \.rdoc$), :desc => <<-__
          An array of patterns that will be used to find the files for which
          documentation should be generated. This is an array of strings that
          will be converted in regular expressions.
        __

        exclude  %w(extconf\.rb$), :desc => <<-__
          An array of patterns that will be used to exclude files from rdoc
          processing. This is an array of strings that will be converted in
          regular expressions.
        __

        main  nil, :desc => <<-__
          The main rdoc file for the project. This defaults to the project's
          README file.
        __

        dir  'doc', :desc => 'Output directory for generated documentation.'
      }
    }

    have?(:rdoc) { true }
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

    unless have? :yard
      desc 'Alias to doc:rdoc'
      task :doc => 'doc:rdoc'
    end

    desc 'Remove all build products'
    task :clobber => %w(doc:clobber_rdoc doc:clobber_ri)

    remove_desc_for_task %w(doc:clobber_rdoc)
  end

end  # module Bones::Plugins::Rdoc

# EOF
