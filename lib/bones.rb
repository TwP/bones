
require 'rubygems'
require 'rake'
require 'rake/clean'
require 'fileutils'
require 'find'
require 'rbconfig'
require 'little-plugger'
require 'loquacious'
require 'git'

module Bones
  extend LittlePlugger

  # :stopdoc:
  VERSION = '3.0.0'
  PATH = File.expand_path(File.join(File.dirname(__FILE__), '..'))
  LIBPATH = File.expand_path(File.join(PATH, 'lib'))
  HOME = File.expand_path(ENV['HOME'] || ENV['USERPROFILE'])

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

  # call-seq:
  #    Bones.config
  #    Bones.config { block }
  #
  def self.config( &block )
    Loquacious.configuration_for('Bones', &block)
  end

end  # module Bones

begin
  $LOAD_PATH.unshift Bones.libpath
  %w[colors helpers gem_package_task annotation_extractor smtp_tls app app/command app/file_manager].
  each { |fn| require File.join('bones', fn) }

  Bones.config {}
  Loquacious.remove :gem, :file, :test
ensure
  $LOAD_PATH.shift
end

module Kernel
  # call-seq:
  #    Bones { block }
  #
  # Configure Mr Bones using the given _block_ of code. If a block is not
  # given, the Bones module is returned.
  #
  def Bones( &block )

    # we absolutely have to have the bones plugin
    plugin_names = ::Bones.plugin_names
    ::Bones.plugin :bones_plugin unless plugin_names.empty? or plugin_names.include? :bones_plugin

    plugins = ::Bones.initialize_plugins.values
    return ::Bones unless block

    config = ::Bones.config
    extend_method = Object.new.method(:extend).unbind.bind(config)
    instance_eval_method = Object.new.method(:instance_eval).unbind.bind(config)

    plugins.each { |plugin|
      ps = plugin.const_get :Syntax rescue next
      extend_method.call ps
    }
    instance_eval_method.call(&block)

    # config.exclude << "^#{Regexp.escape(config.rcov.dir)}/"

    plugins.each { |plugin| plugin.post_load if plugin.respond_to? :post_load }
    plugins.each { |plugin| plugin.define_tasks if plugin.respond_to? :define_tasks }

    rakefiles = Dir.glob(File.join(Dir.pwd, %w[tasks *.rake])).sort
    rakefiles.each {|fn| Rake.application.add_import(fn)}
  end
end

# EOF
