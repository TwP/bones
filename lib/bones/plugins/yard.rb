
module Bones::Plugins::Yard
  include ::Bones::Helpers
  extend self

  def initialize_yard
    require 'yard'
    require 'yard/rake/yardoc_task'
    have?(:yard) { true }

    ::Bones.config {
      desc 'Configuration settings for yard'
      yard {
        opts  [], :desc => 'Array of yard options to use when generating documentation.'

        include  %w(^lib/ ^bin/ ^ext/ \.txt$ \.rdoc$), :desc => <<-__
          An array of patterns that will be used to find the files for which
          documentation should be generated. This is an array of strings that
          will be converted in regular expressions.
        __

        exclude  %w(extconf\.rb$), :desc => <<-__
          An array of patterns that will be used to exclude files from yard
          processing. This is an array of strings that will be converted in
          regular expressions.
        __

        main  nil, :desc => <<-__
          The main yard file for the project. This defaults to the project's
          README file.
        __

        dir  'doc', :desc => 'Output directory for generated documentation.'
      }
    }
  rescue LoadError
    have?(:yard) { false }
  end

  def post_load
    return unless have? :yard
    config = ::Bones.config

    config.exclude << "^#{Regexp.escape(config.yard.dir)}/"
    config.yard.main ||= config.readme_file
  end

  def define_tasks
    return unless have?(:yard)
    config = ::Bones.config

    namespace :doc do
      desc 'Generate Yard documentation'
      YARD::Rake::YardocTask.new(:yard) do |yd|
        yard = config.yard

        incl = Regexp.new(yard.include.join('|'))
        excl = Regexp.new(yard.exclude.join('|'))
        yd.files = config.gem.files.find_all do |fn|
                     case fn
                     when excl; false
                     when incl; true
                     else false end
                   end

        yd.options << '--main' << yard.main
        yd.options << '--output-dir' << yard.dir
        yd.options << '--title' << "#{config.name}-#{config.version} Documentation"

        yd.options.concat(yard.opts)
      end

      task :clobber_yard do
        rm_r config.yard.dir rescue nil
      end
    end  # namespace :doc

    desc 'Alias to doc:yard'
    task :doc => 'doc:yard'

    task :clobber => %w(doc:clobber_yard)
  end

end

# EOF
