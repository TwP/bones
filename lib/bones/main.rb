
require 'fileutils'
require 'optparse'
require 'erb'

module Bones
class Main

  attr_reader :options

  # Create a new instance of Main, and run the +bones+ application given
  # the command line _args_.
  #
  def self.run( args )
    bones = self.new
    bones.parse(args)
    bones.run
  end

  # Create a new main instance using _io_ for standard output and _err_ for
  # error messages.
  #
  def initialize( io = STDOUT, err = STDERR )
    @io = io
    @err = err
    @options = {
      :skeleton_dir => File.join(mrbones_dir, 'data'),
      :with_tasks => false,
      :verbose => false,
      :name => nil,
      :output_dir => nil,
      :action => nil
    }
    @options[:skeleton_dir] = ::Bones.path('data') unless test(?d, skeleton_dir)
  end

  # The output directory where files will be written.
  #
  def output_dir
    options[:output_dir]
  end

  # The directory where the project skeleton is located.
  #
  def skeleton_dir
    options[:skeleton_dir]
  end

  # The project name from the command line.
  #
  def name
    options[:name]
  end

  # Returns the project name but converted to be usable as a Ruby class
  # name.
  #
  def classname
    name.tr('-','_').split('_').map {|x| x.capitalize}.join
  end

  # Returns +true+ if we are updating an already existing project. Returns
  # +false+ if we are creating a new project.
  #
  def update?
    test(?e, output_dir) and with_tasks?
  end

  # Returns +true+ if we are going to copy the Mr Bones tasks into the
  # destination directory. Normally this will return +false+.
  #
  def with_tasks?
    options[:with_tasks]
  end

  # Returns +true+ if the user has requested verbose messages.
  #
  def verbose?
    options[:verbose]
  end

  # Parse the command line arguments and store the values for later use by
  # the +create+ and +update+ methods.
  #
  def parse( args )
    opts = OptionParser.new
    opts.banner << ' project_name'

    opts.separator ''
    opts.on('-v', '--verbose', 'enable verbose output') {
      options[:verbose] = true
    }
    opts.on('-d', '--directory DIRECTORY', String,
            'project directory to create', '(defaults to project_name)') {|dir|
      options[:output_dir] = dir
    }
    opts.on('-s', '--skeleton NAME', String,
            'project skeleton to use') do |skeleton_name|
        path = File.join(mrbones_dir, skeleton_name)
        if test(?d, path)
          options[:skeleton_dir] = path 
        elsif test(?d, skeleton_name)
          options[:skeleton_dir] = skeleton_name
        else
          @io.puts "    unknown skeleton '#{skeleton_name}'"
          exit
        end
      end
    opts.on('--with-tasks', 'copy rake tasks to the project folder') {
      options[:with_tasks] = true
    }

    opts.separator ''
    opts.on('--freeze', 'freeze the project skeleton') {
      options[:action] = :freeze
    }
    opts.on('--unfreeze', 'use the standard project skeleton') {
      options[:action] = :unfreeze
    }
    opts.on('-i', '--info', 'report on the project skeleton being used') {
      options[:action] = :info
    }

    opts.separator ''
    opts.separator 'common options:'
    opts.on_tail( '-h', '--help', 'show this message' ) {
      @io.puts opts
      exit
    }
    opts.on_tail( '--version', 'show version' ) {
      @io.puts "Mr Bones #{::Bones::VERSION}"
      exit
    }

    # parse the command line arguments
    opts.parse! args
    options[:name] = args.empty? ? nil : args.join('_')

    if options[:action].nil? and name.nil?
      @io.puts opts
      ::Kernel.abort
    end

    options[:output_dir] = name if output_dir.nil?
    nil
  end

  # Run the main application.
  #
  def run
    case options[:action]
    when :freeze
      freeze
    when :unfreeze
      unfreeze
    when :info
      @io.puts "the project skeleton will be copied from"
      @io.write "    "
      @io.puts skeleton_dir
    else
      if update? then update
      else create end
    end
  end

  # Create a new project from the bones/data project template.
  #
  def create
    # see if the directory already exists
    abort "'#{output_dir}' already exists" if test ?e, output_dir

    begin
      files_to_copy.each {|fn| cp fn}
      copy_tasks(File.join(output_dir, 'tasks')) if with_tasks?

      pwd = File.expand_path(FileUtils.pwd)
      msg = "created '#{name}'"
      msg << " in directory '#{output_dir}'" if name != output_dir
      @io.puts msg

      if test(?f, File.join(output_dir, 'Rakefile'))
        begin
          FileUtils.cd output_dir
          system "rake manifest:create 2>&1 > #{::Bones::DEV_NULL}"
          @io.puts "now you need to fix these files"
          system "rake notes"
        ensure
          FileUtils.cd pwd
        end
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
    FileUtils.mkdir_p(task_dir) unless test(?d, task_dir)

    archive_dir = File.join(task_dir, 'archive')
    FileUtils.rm_rf archive_dir
    FileUtils.mkdir archive_dir

    Dir.glob(File.join(task_dir, '*')).each do |fn|
      next if fn == archive_dir
      FileUtils.cp fn, archive_dir
    end

    copy_tasks(task_dir)

    msg = "updated tasks for '#{name}'"
    msg << " in directory '#{output_dir}'" if name != output_dir
    @io.puts msg
  end

  # Freeze the project skeleton to the current Mr Bones gem. If the project
  # skeleton has already been frozen, then it will be archived before being
  # overwritten by the current Mr Bones skeleton.
  #
  # If the project skeleton is already frozen, only the tasks from the Mr
  # Bones skeleton will be copied to the user's data directory.
  #
  def freeze
    options[:skeleton_dir] = ::Bones.path('data')
    options[:name]         = 'data' if name.nil?
    options[:output_dir]   = File.join(mrbones_dir, name)

    archive(output_dir, "#{output_dir}.archive")
    FileUtils.mkdir_p(output_dir)

    files_to_copy.each do |file|
      src = File.join(skeleton_dir, file)
      dst = File.join(output_dir, file)

      @io.puts "freezing #{dst}" if verbose?
      FileUtils.mkdir_p(File.dirname(dst))
      FileUtils.cp(src, dst)
    end

    copy_tasks(File.join(output_dir, 'tasks'), 'freezing') if with_tasks?

    File.open(frozen_version_file, 'w') {|fd| fd.puts ::Bones::VERSION}

    @io.puts "project skeleton has been frozen " <<
                  "to Mr Bones #{::Bones::VERSION}"
  end

  # Unfreeze the project skeleton. The default Mr Bones skeleton will be
  # used insetad. This method will archive the current frozen skeleton if
  # one exists.
  #
  def unfreeze
    options[:name]       = 'data' if name.nil?
    options[:output_dir] = File.join(mrbones_dir, name)

    if archive(output_dir, "#{output_dir}.archive")
      @io.puts "project skeleton has been unfrozen"
      @io.puts "(default Mr Bones #{::Bones::VERSION} skeleton will be used)"
    else
      @io.puts "project skeleton is not frozen (no action taken)"
    end
    FileUtils.rm_f frozen_version_file
  end

  # Returns a list of the files to copy from the bones/data directory to
  # the new project directory
  #
  def files_to_copy
    rgxp = %r/\A#{skeleton_dir}\/?/o
    exclude = %r/tmp$|bak$|~$|CVS|\.svn/o

    ary = Dir.glob(File.join(skeleton_dir, '**', '*')).map do |filename|
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
  def cp( file )
    dir = File.dirname(file).sub('NAME', name)
    dir = (dir == '.' ? output_dir : File.join(output_dir, dir))
    dst = File.join(dir,  File.basename(file, '.bns').sub('NAME', name))
    src = File.join(skeleton_dir, file)

    @io.puts(test(?e, dst) ? "updating #{dst}" : "creating #{dst}") if verbose?
    FileUtils.mkdir_p(dir)

    if '.bns' == File.extname(file)
      txt = ERB.new(File.read(src), nil, '-').result(binding)
      File.open(dst, 'w') {|fd| fd.write(txt)}
    else
      FileUtils.cp src, dst
    end

    FileUtils.chmod(File.stat(src).mode, dst)
  end

  # Archive the contents of the _from_ directory into the _to_ directory.
  # The _to_ directory will be deleted if it currently exists. After the
  # copy the _from_ directory will be deleted.
  #
  # Returns +true+ if the directory was archived. Returns +false+ if the
  # directory was not archived.
  #
  def archive( from, to )
    if test(?d, from)
      @io.puts "archiving #{from}" if verbose?
      FileUtils.rm_rf(to)
      FileUtils.mkdir(to)
      FileUtils.cp_r(File.join(from, '.'), to)
      FileUtils.rm_rf(from)
      true
    else
      false
    end
  end

  # Copy the Mr Bones tasks into the _to_ directory. If we are in verbose
  # mode, then a message will be displayed to the user. This message can be
  # passed in as the _msg_ argument. The current file being copied is
  # appened to the end of the message.
  #
  def copy_tasks( to, msg = nil )
    Dir.glob(::Bones.path(%w[lib bones tasks *])).sort.each do |src|
      dst = File.join(to, File.basename(src))

      if msg
        @io.puts "#{msg} #{dst}" if verbose?
      else
        @io.puts(test(?e, dst) ? "updating #{dst}" : "creating #{dst}") if verbose?
      end

      FileUtils.mkdir_p(File.dirname(dst))
      FileUtils.cp(src, dst)
    end
  end

  # Prints an abort _msg_ to the screen and then exits the Ruby interpreter.
  #
  def abort( msg )
    @err.puts msg
    exit 1
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
