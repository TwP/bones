# $Id$

require 'fileutils'
require 'optparse'
require 'erb'

module Bones
class Main

  attr_writer :update
  attr_accessor :name, :data, :verbose, :output_dir

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
    self.data = File.join(mrbones_dir, 'data')
    self.data = File.join(::Bones::PATH, 'data') unless test(?d, data)
    self.update = false
    self.verbose = false

    opts = OptionParser.new
    opts.banner << ' project_name'

    opts.separator ''
    opts.on('-u', '--update',
            'update the rake tasks for the project') {self.update = true}
    opts.on('-v', '--verbose',
            'enable verbose output') {self.verbose = true}
    opts.on('-d', '--directory DIRECTORY', String,
            'project directory to create') {|dir| self.output_dir = dir}

    opts.separator ''
    opts.on('--freeze', 'freeze the project skeleton') {freeze; exit}
    opts.on('--unfreeze', 'use the standard project skeleton') {unfreeze; exit}
    opts.on('-i', '--info',
            'report on the project skeleton being used') do
      STDOUT.puts "the project skeleton will be copied from"
      STDOUT.write "    "
      STDOUT.puts data
      exit
    end

    opts.separator ''
    opts.separator 'common options:'

    opts.on_tail( '-h', '--help', 'show this message' ) {puts opts; exit}
    opts.on_tail( '--version', 'show version' ) do
      puts "Mr Bones #{::Bones::VERSION}"
      exit
    end

    # parse the command line arguments
    opts.parse! args
    self.name = args.empty? ? nil : args.join('_')

    if name.nil?
      puts opts
      ::Kernel.abort
    end

    self.output_dir = name if output_dir.nil?
    nil
  end

  # Returns +true+ if we are updating an already existing project. Returns
  # +false+ if we are creating a new project.
  #
  def update?
    @update
  end

  # Returns the project name but converted to be usable as a Ruby class
  # name.
  #
  def classname
    name.split('_').map {|x| x.capitalize}.join
  end

  # Create a new project from the bones/data project template.
  #
  def create
    # see if the directory already exists
    abort "'#{output_dir}' already exists" if test ?e, output_dir

    begin
      files_to_copy.each {|fn| cp fn}

      pwd = File.expand_path(FileUtils.pwd)
      begin
        FileUtils.cd output_dir
        system "rake manifest:create 2>&1 > #{::Bones::DEV_NULL}"
        msg = "created '#{name}'"
        msg << " in directory '#{output_dir}'" if name != output_dir
        msg << "\nnow you need to fix these files"
        STDOUT.puts msg
        system "rake notes"
      ensure
        FileUtils.cd pwd
      end
    rescue Exception => err
      FileUtils.rm_rf output_dir
      msg = "could not create '#{name}'"
      msg << " in directory '#{output_dir}'" if name != output_dir
      abort msg
    end
  end
  
  # Archive any existing tasks in the project's tasks folder, and then
  # copy in new tasks from the bones/data directory.
  #
  def update
    abort "'#{output_dir}' does not exist" unless test ?e, output_dir

    task_dir = File.join(output_dir, 'tasks')
    abort "no tasks directory found in '#{output_dir}'" unless test ?d, task_dir

    archive_dir = File.join(task_dir, 'archive')
    FileUtils.rm_rf archive_dir
    FileUtils.mkdir archive_dir

    Dir.glob(File.join(task_dir, '*')).each do |fn|
      next if fn == archive_dir
      FileUtils.cp fn, archive_dir
    end

    files_to_copy.each do |fn|
      next unless %r/^tasks\// =~ fn
      cp fn
    end

    msg = "updated tasks for '#{name}'"
    msg << " in directory '#{output_dir}'" if name != output_dir
    STDOUT.puts msg
  end

  # Freeze the project skeleton to the current Mr Bones gem. If the project
  # skeleton has already been frozen, then it will be archived before being
  # overwritten by the current Mr Bones skeleton.
  #
  # If the project skeleton is already frozen, only the tasks from the Mr
  # Bones skeleton will be copied to the user's data directory.
  #
  def freeze
    self.data = File.join(::Bones::PATH, 'data')
    data_dir = File.join(mrbones_dir, 'data')
    archive_dir = File.join(mrbones_dir, 'archive')
    tasks_only = false

    if test(?d, data_dir)
      STDOUT.puts "archiving #{data_dir}" if verbose
      FileUtils.rm_rf(archive_dir)
      FileUtils.mkdir(archive_dir)
      FileUtils.cp_r(File.join(data_dir, '.'), archive_dir)
      tasks_only = true
    else
      FileUtils.mkdir_p(data_dir)
    end

    files_to_copy.each do |file|
      next if tasks_only && !(%r/^tasks\// =~ file)

      src = File.join(data, file)
      dst = File.join(data_dir, file)

      STDOUT.puts "freezing #{dst}" if verbose
      FileUtils.mkdir_p(File.dirname(dst))
      FileUtils.cp(src, dst)
    end

    File.open(frozen_version_file, 'w') {|fd| fd.puts ::Bones::VERSION}

    if tasks_only
      STDOUT.puts "project skeleton tasks have been updated " <<
                  "from Mr Bones #{::Bones::VERSION}"
    else
      STDOUT.puts "project skeleton has been frozen " <<
                  "to Mr Bones #{::Bones::VERSION}"
    end
  end

  # Unfreeze the project skeleton. The default Mr Bones skeleton will be
  # used insetad. This method will archive the current frozen skeleton if
  # one exists.
  #
  def unfreeze
    data_dir = File.join(mrbones_dir, 'data')
    archive_dir = File.join(mrbones_dir, 'archive')

    if test(?d, data_dir)
      STDOUT.puts "archiving #{data_dir}" if verbose
      FileUtils.rm_rf(archive_dir)
      FileUtils.mkdir(archive_dir)
      FileUtils.cp_r(File.join(data_dir, '.'), archive_dir)
      FileUtils.rm_rf(data_dir)

      STDOUT.puts "project skeleton has been unfrozen"
      STDOUT.puts "(default Mr Bones #{::Bones::VERSION} sekeleton will be used)"
    else
      STDOUT.puts "project skeleton is not frozen (no action taken)"
    end
    FileUtils.rm_f frozen_version_file
  end


  private

  # Copy a file from the Bones prototype project location to the user
  # specified project location. A message will be displayed to the screen
  # indicating that the file is being created.
  #
  def cp( file )
    dir = File.dirname(file).sub('NAME', name)
    dir = (dir == '.' ? output_dir : File.join(output_dir, dir))
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

  # Returns the .bones resource directory in the user's home directory.
  #
  def mrbones_dir
    return @mrbones_dir if defined? @mrbones_dir

    path = (::Bones::WIN32 ? ENV['HOMEPATH'].tr("\\", "/") : ENV['HOME'])
    path = File.join(path, '.mrbones')
    @mrbones_dir = File.expand_path(path)
  end

  # File containing the Mr Bones version from which the skeleton was frozen.
  #
  def frozen_version_file
    File.join(mrbones_dir, 'version.txt')
  end

end  # class Main
end  # module Bones

# EOF
