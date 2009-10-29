
module Bones::App

class Command

  attr_reader :options

  def initialize( params, out = STDOUT, err = STDERR )
    @out = out
    @err = err
    normalize params
  end

  def run( args )
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

  def normalize( params )
    p = params.to_options
    @options = {
      :skeleton_dir => File.join(mrbones_dir, 'data'),
      :verbose => false,
      :name => nil,
      :output_dir => nil
    }
    @options[:skeleton_dir] = ::Bones.path('data') unless test(?d, skeleton_dir)
    @options[:output_dir] ||= @options[:name]

    {
      :name         => p['project_name'],
      :verbose      => p['verbose'] ? true : false,
      :output_dir   => p['directory'],
      :skeleton_dir => p['skeleton'],
      :repository   => p['repository']
    }
  end

  #
  #
  def standard_options
    {
      :verbose => ['-v', '--verbose', 'enable verbose output',
          lambda {
            options[:verbose] = true
          }],
      :directory => ['-d', '--directory DIRECTORY', String,
          'project directory to create', '(defaults to project_name)',
          lambda { |value|
            options[:output_dir] = value
          }],
      :skeleton => ['-s', '--skeleton NAME', String,
          'project skeleton to use',
          lambda { |value|
            path = File.join(mrbones_dir, value)
            if test(?e, path)
              options[:skeleton_dir] = path 
            elsif test(?e, value)
              options[:skeleton_dir] = value
            else
              raise ArgumentError, "Unknown skeleton '#{value}'"
            end
          }],
      :repository => ['-r', '--repository URL', String,
          'svn or git repository path', 
          lambda { |value|
            options[:repository] = value
          }]
    }
  end

end  # class Command
end  # module Bones::App

# EOF
