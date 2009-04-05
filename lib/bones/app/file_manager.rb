
require 'fileutils'

module Bones
class App

class FileManager

  attr_accessor :source, :destination, :archive, :verbose
  alias :verbose? :verbose

  #
  #
  def initialize( opts = {} )
    self.source = opts[:source]
    self.destination = opts[:destination]
    self.verbose = opts[:verbose]

    @out = opts[:stdout] || $stdout
    @err = opts[:stderr] || $stderr
  end

  # Sets the destination where files will be copied to. At the same time an
  # archive directory is configured. This is simply the destination
  # directory with a '.archive' extension.
  #
  def destination=( str )
    @destination = str
    @archive = str + '.archive' if str
  end

  # If the source is a repository this method returns the type of
  # repository. This will be :git for Git repositories and :svn for
  # Subversion repositories. Otherwise, +nil+ is returned.
  #
  def repository
    return :git if source =~ %r/\.git\/?$/i
    return :svn if source =~ %r/^(svn(\+ssh)?|https?|file):\/\//i
    nil
  end
  alias :repository? :repository

  #
  #
  def archive_destination
    return false unless test(?e, destination)

    @out.puts "archiving #{destination}" if verbose?
    FileUtils.rm_rf(archive)
    FileUtils.mv(destination, archive)
    true
  end

  #
  #
  def copy
    if repository?
      _checkout(repository)
    else
      _files_to_copy.each {|fn| _cp(fn)}
    end
  end

  #
  #
  def finalize( name )
    name = name.to_s
    return if name.empty?

    self.destination = _rename(destination, name)
    _erb(name)

    self
  end

  #
  #
  def _checkout( repotype )
    case repotype
    when :git
      system('git-clone', source, destination)
      FileUtils.rm_rf(File.join(destination, '.git'))
    when :svn
      system('svn', 'export', source, destination)
    else
      raise "unknown repository type '#{repotype}'"
    end
  end

  #
  #
  def _rename( filename, name )
    newname = filename.gsub(%r/NAME/, name)

    if filename != newname
      raise "cannot rename '#{filename}' to '#{newname}' - file already exists" if test(?e, newname)
      FileUtils.mv(filename, newname)
    end

    if test(?d, newname)
      Dir.glob(File.join(newname, '*')).each {|fn| _rename(fn, name)}
    end
    newname
  end

  #
  #
  def _erb( name )
    binding = _erb_binding(name)

    Dir.glob(File.join(destination, '**', '*')).each do |fn|
      next unless test(?f, fn) and '.bns' == File.extname(fn)

      txt = ERB.new(File.read(fn), nil, '-').result(binding)
      File.open(fn.sub(%r/\.bns$/, ''), 'w') {|fd| fd.write(txt)}
      FileUtils.rm_f(fn)
    end
    self
  end

  #
  #
  def _erb_binding( name )
    obj = Object.new
    class << obj
      alias :__binding__ :binding
      instance_methods.each {|m| undef_method m unless m[%r/^(__|object_id)/]}
      def binding(name)
        classname = name.tr('-','_').split('_').map {|x| x.capitalize}.join
        __binding__
      end
    end
    obj.binding name
  end

  # Returns a list of the files to copy from the source directory to
  # the destination directory.
  #
  def _files_to_copy
    rgxp = %r/\A#{source}\/?/
    exclude = %r/tmp$|bak$|~$|CVS|\.svn/

    ary = Dir.glob(File.join(source, '**', '*'), File::FNM_DOTMATCH).map do |filename|
      next if exclude =~ filename
      next if test(?d, filename)
      filename.sub rgxp, ''
    end

    ary.compact!
    ary.sort!
    ary
  end

  # Copy a file from the Bones prototype project location to the user
  # specified project location. A message will be displayed to the screen
  # indicating that the file is being created.
  #
  def _cp( file )
    dir = File.dirname(file)
    dir = (dir == '.' ? destination : File.join(destination, dir))
    dst = File.join(dir,  File.basename(file))
    src = File.join(source, file)

    @out.puts(test(?e, dst) ? "updating #{dst}" : "creating #{dst}") if verbose?
    FileUtils.mkdir_p(dir)
    FileUtils.cp src, dst

    FileUtils.chmod(File.stat(src).mode, dst)
  end

end  # class FileManager
end  # class App
end  # module Bones

# EOF
