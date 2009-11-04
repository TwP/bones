
require 'rake/testtask'

module Bones::Plugins::Test
  include ::Bones::Helpers
  extend self

  def initialize_test
    ::Bones.config {
      desc 'Configuration settings for the Ruby test framework.'
      test {
        files FileList['test/**/test_*.rb'], :desc => <<-__
          The list of test files to run. This defaults to all the ruby fines
          in the 'test' directory that start with 'test_' as their filename.
        __

        file 'test/all.rb', :desc => <<-__
          In fashion at one time was the concept of an encompassing test file
          that would run all ruby tests for your project. You can specify that
          file here. If the file does not exist this setting will be ignored.
        __

        opts [], :desc => <<-__
          Extra ruby options to be used when running tests.
        __
      }
    }
  end

  def post_load
    config = ::Bones.config
    have?(:test) {
      Kernel.test(?e, config.test.file) or not config.test.files.to_a.empty?
    }
  end

  def define_tasks
    return unless have? :test
    config = ::Bones.config

    namespace :test do
      Rake::TestTask.new(:run) do |t|
        t.libs = config.libs
        t.test_files = if test(?f, config.test.file) then [config.test.file]
                       else config.test.files end
        t.ruby_opts += config.ruby_opts
        t.ruby_opts += config.test.opts
      end
    end  # namespace :test

    desc 'Alias to test:run'
    task :test => 'test:run'
  end

end

# EOF
