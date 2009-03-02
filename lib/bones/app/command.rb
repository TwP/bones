
module Bones
class App

class Command

  attr_reader :options

  def initialize( out = STDOUT, err = STDERR )
    @out = out
    @err = err
    @options = {
      :skeleton_dir => File.join(mrbones_dir, 'data'),
      :with_tasks => false,
      :verbose => false,
      :name => nil,
      :output_dir => nil
    }
    @options[:skeleton_dir] = ::Bones.path('data') unless test(?d, skeleton_dir)
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

  # Returns +true+ if we are going to copy the Mr Bones tasks into the
  # destination directory. Normally this will return +false+.
  #
  def with_tasks?
    options[:with_tasks]
  end

  #
  #
  def copy_tasks( to )
    fm = FileManager.new(
      :source => ::Bones.path(%w[lib bones tasks]),
      :destination => to,
      :stdout => @out,
      :stderr => @err,
      :verbose => verbose?
    )
    fm.archive_destination
    fm.copy
  end

  # Returns +true+ if the user has requested verbose messages.
  #
  def verbose?
    options[:verbose]
  end

  # Returns the .bones resource directory in the user's home directory.
  #
  def mrbones_dir
    return @mrbones_dir if defined? @mrbones_dir

    path = File.join(::Bones::HOME, '.mrbones')
    @mrbones_dir = File.expand_path(path)
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
      :with_tasks => ['--with-tasks', 'copy rake tasks to the project folder',
          lambda {
            options[:with_tasks] = true
          }],
      :repository => ['-r', '--repository URL', String,
          'svn or git repository path', 
          lambda { |value|
            options[:repository] = value
          }]
    }
  end

end  # class Command
end  # class App
end  # module Bones

# EOF
