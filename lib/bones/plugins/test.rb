
require 'rake/testtask'

Loquacious.remove :test, :file

module Bones::Plugins::Test
  include ::Bones::Helpers
  extend self

  def initialize_test
    ::Bones.config {
      test {
        files  FileList['test/**/test_*.rb']
        file   'test/all.rb'
        opts   []
      }
    }
  end

  def define_tasks
    config = ::Bones.config
    return unless Kernel.test(?e, config.test.file) or not config.test.files.to_a.empty?

    namespace :test do

      Rake::TestTask.new(:run) do |t|
        t.libs = config.libs
        t.test_files = if test(?f, config.test.file) then [config.test.file]
                       else config.test.files end
        t.ruby_opts += config.ruby_opts
        t.ruby_opts += config.test.opts
      end

      if HAVE_RCOV
        desc 'Run rcov on the unit tests'
        task :rcov => :clobber_rcov do
          opts = config.rcov.opts.dup << '-o' << config.rcov.dir
          opts = opts.join(' ')
          files = if test(?f, config.test.file) then [config.test.file]
                  else config.test.files end
          files = files.join(' ')
          sh "#{RCOV} #{files} #{opts}"
        end

        task :clobber_rcov do
          rm_r 'coverage' rescue nil
        end
      end

    end  # namespace :test

    desc 'Alias to test:run'
    task :test => 'test:run'

    task :clobber => 'test:clobber_rcov' if HAVE_RCOV
  end

end

# EOF
