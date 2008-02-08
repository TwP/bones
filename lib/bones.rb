# $Id$

module Bones

  # :stopdoc:
  VERSION = '1.3.3'
  PATH = File.expand_path(File.join(File.dirname(__FILE__), '..'))
  WIN32 = %r/win32/ =~ RUBY_PLATFORM
  DEV_NULL = WIN32 ? 'NUL:' : '/dev/null'
  # :startdoc:

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
        File.join(File.dirname(fname), dir, '**', '*.rb'))

    Dir.glob(search_me).sort.each {|rb| require rb}
  end

  # TODO: fix file lists for Test::Unit and RSpec
  #       these guys are just grabbing whatever is there and not pulling
  #       the filenames from the manifest

  # TODO: create some tasks to generate e-mails / announcements
  
end  # module Bones


Bones.require_all_libs_relative_to __FILE__

# EOF
