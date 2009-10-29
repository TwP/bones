
require 'rubygems'
require 'rbconfig'
require 'little-plugger'
require 'loquacious'

module Bones
  extend LittlePlugger

  # :stopdoc:
  VERSION = '3.0.0'
  PATH = File.expand_path(File.join(File.dirname(__FILE__), '..'))
  LIBPATH = File.expand_path(File.join(PATH, 'lib'))
  HOME = File.expand_path(ENV['HOME'] || ENV['USERPROFILE'])
  DEV_NULL = File.exist?('/dev/null') ? '/dev/null' : 'NUL:'

  # Ruby Interpreter location - taken from Rake source code
  RUBY = File.join(Config::CONFIG['bindir'],
                   Config::CONFIG['ruby_install_name']).sub(/.*\s.*/m, '"\&"')

  module Plugins; end
  # :startdoc:

  # Returns the path for Mr Bones. If any arguments are given,
  # they will be joined to the end of the path using <tt>File.join</tt>.
  #
  def self.path( *args )
    args.empty? ? PATH : File.join(PATH, args.flatten)
  end

  # Returns the lib path for Mr Bones. If any arguments are given,
  # they will be joined to the end of the path using <tt>File.join</tt>.
  #
  def self.libpath( *args )
    args.empty? ? LIBPATH : File.join(LIBPATH, args.flatten)
  end

  #
  #
  def self.config( &block )
    Loquacious.configuration_for('Bones', &block)
  end

  #
  #
  def self.import( *args )
    @import ||= []

    path = File.dirname(caller.first.split(':').first)
    args.flatten!

    args.map! { |fn|
      fp = File.join(path, fn)
      break fp if test ?f, fp

      fp = File.join(path, 'tasks', fn)
      break fp if test ?f, fp

      nil
    }

    args.compact!
    @import.concat args
    @import
  end

  # call-seq:
  #    Bones.setup
  #
  #
  def self.setup
    local_setup = File.join(Dir.pwd, %w[tasks setup.rb])

    if test(?e, local_setup)
      load local_setup
      return
    end

    bones_setup = ::Bones.path %w[lib bones tasks setup.rb]
    load bones_setup

    rakefiles = Dir.glob(File.join(Dir.pwd, %w[tasks *.rake])).sort
    rakefiles.each {|fn| Rake.application.add_import(fn)}
  end

  # TODO: fix file lists for Test::Unit and RSpec
  #       these guys are just grabbing whatever is there and not pulling
  #       the filenames from the manifest

end  # module Bones

class Loquacious::Configuration; undef :gem if defined? :gem; end
class Loquacious::Configuration::DSL; undef :gem if defined? :gem; end

begin
  $LOAD_PATH.unshift Bones.libpath
  require 'bones/config'
  require 'bones/gem_package_task'
ensure
  $LOAD_PATH.shift
end

module Kernel
  def Bones( &block )

    ::Bones.initialize_plugins
    return ::Bones
  end
end

# EOF
