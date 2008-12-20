
module Bones
class App

class FileManager

  attr_accessor :source, :destination, :archive

  def initialize( opts = {} )
    self.source = opts[:source]
    self.destination = opts[:destination]
  end

  def destination=( str )
    @destination = str
    @archive = str + '.archive' if str
  end

  def repository
    return :git if source =~ %r/\.git\/?$/i
    return :svn if source =~ %r/^(svn(\+ssh)?|https?|file):\/\//i
    nil
  end
  alias :repository? :repository

  def copy
  end

  # Returns a list of the files to copy from the source directory to
  # the destinationdirectory.
  #
  def files_to_copy
    rgxp = %r/\A#{source}\/?/o
    exclude = %r/tmp$|bak$|~$|CVS|\.svn/o

    ary = Dir.glob(File.join(source, '**', '*')).map do |filename|
      next if exclude =~ filename
      next if test(?d, filename)
      filename.sub rgxp, ''
    end

    ary.compact!
    ary.sort!
    ary
  end

end  # class FileManager
end  # class App
end  # module Bones

# EOF
