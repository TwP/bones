
class Bones::App::Command
  include Bones::Colors

  # :stopdoc:
  DEFAULT_SKELETON = 'default'
  Bones.config() { colorize = true }
  # :startdoc:

  attr_reader :stdout
  attr_reader :stderr
  attr_reader :config

  def initialize( opts = {} )
    @stdout = opts[:stdout] || $stdout
    @stderr = opts[:stderr] || $stderr

    @config = {
      :skeleton_dir => File.join(mrbones_dir, DEFAULT_SKELETON),
      :verbose => false,
      :name => nil,
      :output_dir => nil,
    }
    @config[:skeleton_dir] = ::Bones.path(DEFAULT_SKELETON) unless test(?d, skeleton_dir)
  end

  def run( args )
    raise NotImplementedError
  end

  # The output directory where files will be written.
  #
  def output_dir
    @config[:output_dir]
  end

  # The directory where the project skeleton is located.
  #
  def skeleton_dir
    @config[:skeleton_dir]
  end

  # The project name from the command line.
  #
  def name
    @config[:name]
  end

  # A git or svn repository URL from the command line.
  #
  def repository
    return @config[:repository] if @config.has_key? :repository
    return IO.read(skeleton_dir).strip if skeleton_dir and test(?f, skeleton_dir)
    nil
  end

  # Returns +true+ if the user has requested verbose messages.
  #
  def verbose?
    @config[:verbose]
  end

  # Returns the '.mrbones' resource directory in the user's home directory.
  #
  def mrbones_dir
    return @mrbones_dir if defined? @mrbones_dir

    path = File.join(::Bones::HOME, '.mrbones')
    @mrbones_dir = File.expand_path(path)
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

  #
  #
  def standard_options
    Command.standard_options
  end

  #
  #
  def parse( args )
    opts = OptionParser.new

    opts.banner = 'NAME'
    opts.separator "  bones v#{::Bones.version}"
    opts.separator ''

    if self.class.synopsis
      opts.separator 'SYNOPSIS'
      self.class.synopsis.split("\n").each { |line| opts.separator "  #{line.strip}" }
      opts.separator ''
    end

    if self.class.description
      opts.separator 'DESCRIPTION'
      self.class.description.split("\n").each { |line| opts.separator "  #{line.strip}" }
      opts.separator ''
    end

    if self.class.options and not self.class.options.empty?
      opts.separator 'PARAMETERS'
      self.class.options.each { |option|
        case option
        when Array
          option << method(option.pop) if option.last =~ %r/^__/
          opts.on(*option)
        when String
          opts.separator("  #{option.strip}")
        else opts.separator('') end
      }
      opts.separator ''
    end

    opts.separator '  Common Options:'
    opts.on_tail( '-h', '--help', 'show this message' ) {
      stdout.puts opts
      exit
    }
    opts.on_tail ''

    opts.parse! args
    return opts
  end

  # Returns a hash of the standard options that can be used for individual
  # commadns.
  #
  def self.standard_options
    @standard_options ||= {
      :verbose => ['-v', '--verbose', 'Enable verbose output.',
          lambda { config[:verbose] = true }],

      :directory => ['-d', '--directory DIRECTORY', String,
          'Project directory to create.',  '(defaults to project_name)',
          lambda { |value| config[:output_dir] = value }],

      :skeleton => ['-s', '--skeleton NAME', String,
          'Project skeleton to use.',
          lambda { |value|
            path = File.join(mrbones_dir, value)
            if test(?e, value)
              config[:skeleton_dir] = value
            elsif test(?e, path)
              config[:skeleton_dir] = path
            else
              raise ArgumentError, "Unknown skeleton '#{value}'."
            end
          }],

      :repository => ['-r', '--repository URL', String,
          'svn or git repository path.',
          lambda { |value| config[:repository] = value }],

      :colorize => ['-c', '--color', '--no-color', 'Colorize output',
          lambda { |value| Bones.config.colorize = value }]
    }
  end

  module ClassMethods
    def synopsis( *args )
      @synopsis = args.join("\n") unless args.empty?
      @synopsis
    end

    def description( *args )
      @description = args.join("\n") unless args.empty?
      @description
    end

    def summary( *args )
      @summary = args.join("\n") unless args.empty?
      @summary
    end

    def option( *args, &block )
      args.flatten!
      block = args.pop if block.nil? and Proc === args.last

      if block
        args.each { |val|
          next unless val.instance_of? String
          next unless val =~ %r/^--(\w+)/

          args << "__#$1"
          define_method(args.last.to_sym, &block)
          options << args
          break
        }
      else
        options << (args.length > 1 ? args : args.first )
      end
    end

    def options
      @options ||= []
    end
  end

  def self.inherited( other )
    other.extend ClassMethods
  end

end  # class Bones::App::Command

# EOF
