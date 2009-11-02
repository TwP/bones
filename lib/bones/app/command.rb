
module Bones::App

class Command

  # Run the current command using the given Main _params_ table.
  #
  def self.run( params )
    new(params).run
  end

  attr_reader :options

  #
  #
  def initialize( params, out = STDOUT, err = STDERR )
    @out = out
    @err = err
    normalize params
  end

  # Implemented by subclasses.
  #
  def run
    raise NotImplementedError
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

  # A git or svn repository URL from the command line.
  #
  def repository
    return options[:repository] if options.has_key? :repository
    return IO.read(skeleton_dir).strip if skeleton_dir and test(?f, skeleton_dir)
    nil
  end

  # Returns +true+ if the user has requested verbose messages.
  #
  def verbose?
    options[:verbose]
  end

  # Returns the .mrbones resource directory in the user's home directory.
  #
  def mrbones_dir
    return @mrbones_dir if defined? @mrbones_dir

    path = File.join(::Bones::HOME, '.mrbones')
    @mrbones_dir = File.expand_path(path)
  end

  # Take the Main _params_ and convert them into an options hash usable by the
  # command objects.
  #
  def normalize( params )
    @params = params.to_options
    @options = {
      :name         => @params['project_name'] || @params['skeleton_name'],
      :verbose      => @params['verbose'] ? true : false,
      :repository   => @params['repository'],
      :output_dir   => @params['directory'],
      :skeleton_dir => nil
    }

    if value = @params['skeleton']
      path = File.join(mrbones_dir, value)
      if test(?e, path)
        @options[:skeleton_dir] = path
      elsif test(?e, value)
        @options[:skeleton_dir] = value
      else
        raise ArgumentError, "Unknown skeleton '#{value}'"
      end
    else
      @options[:skeleton_dir] = File.join(mrbones_dir, 'data')
    end

    @options[:skeleton_dir] = ::Bones.path('data') unless test(?d, skeleton_dir)
    @options[:output_dir] ||= @options[:name]
  end

  # Run a block of code in the given directory.
  #
  def in_directory( dir )
    pwd = File.expand_path(FileUtils.pwd)
    FileUtils.cd dir
    yield
  ensure
    FileUtils.cd pwd
  end

end  # class Command
end  # module Bones::App

# EOF
