# $Id$

require 'fileutils'
require 'optparse'
require 'erb'

module Bones
class Main

  attr_writer :update
  attr_accessor :name, :data, :verbose

  # Create a new instance of Main, and run the +bones+ application given
  # the command line _args_.
  #
  def self.run( args )
    bones = self.new
    bones.parse args

    if bones.update? then bones.update
    else bones.create end
  end

  # Parse the command line arguments and store the values for later use by
  # the +create+ and +update+ methods.
  #
  def parse( args )
    self.data = File.join(::Bones::PATH, 'data')
    self.update = false
    self.verbose = false

    opts = OptionParser.new
    opts.banner << ' project_name'

    opts.separator ''
    opts.on('-u', '--update',
            'update the rake tasks for the project') {self.update = true}
    opts.on('-v', '--verbose',
            'enable verbose output') {self.verbose = true}

    opts.separator ''
    opts.separator 'common options:'

    opts.on_tail( '-h', '--help', 'show this message' ) {puts opts; exit}
    opts.on_tail( '--version', 'show version' ) do
      puts "Bones #{::Bones::VERSION}"
      exit
    end

    # parse the command line arguments
    opts.parse! args
    self.name = args.shift

    if name.nil?
      puts opts
      ::Kernel.abort
    end
    nil
  end

  # Returns +true+ if we are updating an already existing project. Returns
  # +false+ if we are creating a new project.
  #
  def update?
    @update
  end

  # Returns the project name but converted to be useable as a Ruby class
  # name.
  #
  def classname
    name.split('_').map {|x| x.capitalize}.join
  end

  # Create a new project from the bones/data project template.
  #
  def create
    # * copy files from either
    #   1) the user's '.bones/data' directory or
    #   2) the Bones 'data' directory
    #
    # TODO - figure out if this really is the best way of doing this
    #        should I just use either the .bones data or the gem data, not
    #        both

    # see if the directory already exists
    abort "'#{name}' already exists" if test ?e, name

    begin
      files_to_copy.each {|fn| cp fn}

      pwd = File.expand_path(FileUtils.pwd)
      begin
        FileUtils.cd name
        system "rake manifest:create 2>&1 > #{::Bones::DEV_NULL}"
      ensure
        FileUtils.cd pwd
      end
    rescue Exception => err
      FileUtils.rm_rf name
      abort "could not create '#{name}'"
    end

    STDOUT.puts "created '#{name}'"
  end
  
  # Archive any existing tasks in the project's tasks folder, and then
  # copy in new tasks from the bones/data directory.
  #
  def update
    abort "'#{name}' does no exist" unless test ?e, name

    task_dir = File.join(name, 'tasks')
    abort "no tasks directory found in '#{name}'" unless test ?d, task_dir

    archive_dir = File.join(task_dir, 'archive')
    FileUtils.rm_rf archive_dir
    FileUtils.mkdir archive_dir

    Dir.glob(File.join(task_dir, '*')).each do |fn|
      next if fn == archive_dir
      FileUtils.cp fn, archive_dir
    end

    files_to_copy.each do |fn|
      next unless 'tasks' == File.basename(File.dirname(fn))
      cp fn
    end

    STDOUT.puts "updated tasks for '#{name}'"
  end


  private

  # Copy a file from the Bones prototype project location to the user
  # specified project location. A message will be displayed to the screen
  # indicating tha the file is being created.
  #
  def cp( file )
    dir = File.dirname(file)
    dir = (dir == '.' ? name : File.join(name, dir))
    dst = File.join(dir,  File.basename(file, '.erb').sub('NAME', name))
    src = File.join(data, file)

    puts (test(?e, dst) ? "updating #{dst}" : "creating #{dst}") if verbose
    FileUtils.mkdir_p(dir)

    if '.erb' == File.extname(file)
      txt = ERB.new(File.read(src), nil, '-').result(binding)
      File.open(dst, 'w') {|fd| fd.write(txt)}
    else
      FileUtils.cp src, dst
    end

    FileUtils.chmod(File.stat(src).mode, dst)
  end

  # Prints an abort _msg_ to the screen and then exits the Ruby interpreter.
  #
  def abort( msg )
    STDERR.puts msg
    exit 1
  end

  # Returns a list of the files to copy from the bones/data directory to
  # the new project directory
  #
  def files_to_copy
    rgxp = %r/\A#{data}\/?/o
    exclude = %r/tmp$|bak$|~$|CVS|\.svn/o

    ary = Dir.glob(File.join(data, '**', '*')).map do |filename|
      next if exclude =~ filename
      next if test(?d, filename)
      filename.sub rgxp, ''
    end

    ary.compact!
    ary.sort!
    ary
  end

end  # class Main
end  # module Bones

# EOF
