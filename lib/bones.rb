
require 'rbconfig'

module Bones

  # :stopdoc:
  VERSION = '2.5.1'
  PATH = File.expand_path(File.join(File.dirname(__FILE__), '..'))
  HOME = File.expand_path(ENV['HOME'] || ENV['USERPROFILE'])
  DEV_NULL = File.exist?('/dev/null') ? '/dev/null' : 'NUL:'

  # Ruby Interpreter location - taken from Rake source code
  RUBY = File.join(Config::CONFIG['bindir'],
                   Config::CONFIG['ruby_install_name']).sub(/.*\s.*/m, '"\&"')
  # :startdoc:

  # Returns the path for Mr Bones. If any arguments are given,
  # they will be joined to the end of the path using
  # <tt>File.join</tt>.
  #
  def self.path( *args )
    args.empty? ? PATH : File.join(PATH, args.flatten)
  end

  # call-seq:
  #    Bones.require_all_libs_relative_to( filename, directory = nil )
  #
  # Utility method used to rquire all files ending in .rb that lie in the
  # directory below this file that has the same name as the filename passed
  # in. Optionally, a specific _directory_ name can be passed in such that
  # the _filename_ does not have to be equivalent to the directory.
  #
  def self.require_all_libs_relative_to( fname, dir = nil )
    dir ||= File.basename(fname, '.*')
    search_me = File.expand_path(
        File.join(File.dirname(fname), dir, '*.rb'))

    Dir.glob(search_me).sort.each {|rb| require rb}
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

Bones.require_all_libs_relative_to(__FILE__)

# EOF
