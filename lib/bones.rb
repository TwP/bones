
require 'rubygems'
require 'rake'
require 'rake/clean'
require 'pathname'
require 'fileutils'
require 'find'
require 'rbconfig'
require 'little-plugger'
require 'loquacious'

module Bones
  extend LittlePlugger

  # :stopdoc:
  PATH = File.expand_path('../..', __FILE__) + File::SEPARATOR
  LIBPATH = File.expand_path('..', __FILE__) + File::SEPARATOR
  HOME = File.expand_path(ENV['HOME'] || ENV['USERPROFILE'])
  RUBY = 'ruby'

  module Plugins; end
  # :startdoc:

  # Returns the path for Mr Bones. If any arguments are given,
  # they will be joined to the end of the path using `File.join`.
  def self.path(*args)
    rv = args.empty? ? PATH : ::File.join(PATH, args.flatten)
    if block_given?
      begin
        $LOAD_PATH.unshift PATH
        rv = yield
      ensure
        $LOAD_PATH.shift
      end
    end
    return rv
  end

  # Returns the lib path for Mr Bones. If any arguments are given,
  # they will be joined to the end of the path using `File.join`.
  def self.libpath(*args)
    rv =  args.empty? ? LIBPATH : ::File.join(LIBPATH, args.flatten)
    if block_given?
      begin
        $LOAD_PATH.unshift LIBPATH
        rv = yield
      ensure
        $LOAD_PATH.shift
      end
    end
    return rv
  end

  # call-seq:
  #    Bones.config
  #    Bones.config { block }
  #
  # Returns the configuration object for setting up Mr Bones options.
  #
  def self.config(&block)
    Loquacious.configuration_for('Bones', &block)
  end

  # call-seq:
  #    Bones.help
  #
  # Returns a help object that can be used to show the current Mr Bones
  # configuration and descriptions for the various configuration attributes.
  #
  def self.help
    Loquacious.help_for('Bones', colorize: config.colorize, nesting_nodes: false)
  end
end

Bones.libpath {
  require 'bones/version'
  require 'bones/colors'
  require 'bones/helpers'
  require 'bones/rake_override_task'
  require 'bones/gem_package_task'
  require 'bones/annotation_extractor'
  require 'bones/app'
  require 'bones/app/command'
  require 'bones/app/file_manager'

  Bones.config {}
  Loquacious.remove(:gem, :file, :test, :timeout)
}

module Kernel
  # call-seq:
  #    Bones { block }
  #
  # Configure Mr Bones using the given _block_ of code. If a block is not
  # given, the Bones module is returned.
  #
  def Bones(filename = nil, &block)

    # we absolutely have to have the bones plugin
    plugin_names = ::Bones.plugin_names
    ::Bones.plugin :bones_plugin unless plugin_names.empty? || plugin_names.include?(:bones_plugin)

    plugins = ::Bones.initialize_plugins.values
    ::Bones::Plugins::Gem.import_gemspec(filename) if filename
    return ::Bones unless block

    extend_method = Object.instance_method(:extend).bind(::Bones.config)
    plugins.each do |plugin|
      ps = plugin.const_get(:Syntax) rescue next
      extend_method.call(ps)
    end

    instance_eval_method = Object.instance_method(:instance_eval).bind(::Bones.config)
    instance_eval_method.call(&block)

    plugins.each {|plugin| plugin.post_load if plugin.respond_to?(:post_load)}
    plugins.each {|plugin| plugin.define_tasks if plugin.respond_to?(:define_tasks)}

    rakefiles = Dir.glob(File.join(Dir.pwd, %w[tasks *.rake])).sort
    rakefiles.each {|fn| Rake.application.add_import(fn)}
  end
end

