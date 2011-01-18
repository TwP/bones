
require 'net/http'
require 'uri'

module Bones::App
  extend LittlePlugger(:path => 'bones/app', :module => Bones::App)
  disregard_plugins :error, :main, :command, :file_manager

  Error = Class.new(StandardError)

  # Create a new instance of Main, and run the +bones+ application given
  # the command line _args_.
  #
  def self.run( args = nil )
    args ||= ARGV.dup.map! { |v| v.dup }
    ::Bones::App::Main.new.run args
  end

  class Main
    include Bones::Colors
    attr_reader :stdout
    attr_reader :stderr

    # Create a new Main application instance. Options can be passed to
    # configuret he stdout and stderr IO streams (very useful for testing).
    #
    def initialize( opts = {} )
      opts[:stdout] ||= $stdout
      opts[:stderr] ||= $stderr

      @opts = opts
      @stdout = opts[:stdout]
      @stderr = opts[:stderr]
    end

    # Parse the desired user command and run that command object.
    #
    def run( args )
      commands = []
      @plugins = ::Bones::App.plugins
      @plugins.each { |k,v| commands << k.to_s if v < ::Bones::App::Command }

      cmd_str = args.shift
      cmd = case cmd_str
        when *commands
          key = cmd_str.to_sym
          @plugins[key].new @opts
        when nil, '-h', '--help'
          help
        when '-v', '--version'
          stdout.puts "Mr Bones v#{::Bones.version}"
        else
          raise Error, "Unknown command #{cmd_str.inspect}"
        end

      if cmd
        cmd.parse args
        cmd.run
      end

    rescue Bones::App::Error => err
      stderr.puts "#{colorize('ERROR', :white, :on_red)}:  While executing bones ..."
      stderr.puts "    #{err.message}"
      exit 1
    rescue StandardError => err
      stderr.puts "#{colorize('ERROR', :white, :on_red)}:  While executing bones ... (#{colorize(err.class, :red)})"
      stderr.puts "    #{err.to_s}"
      exit 1
    end

    # Show the toplevel Mr Bones help message.
    #
    def help
      msg = <<-MSG
NAME
  bones v#{::Bones.version}

DESCRIPTION
  Mr Bones is a handy tool that builds a skeleton for your new Ruby
  projects. The skeleton contains some starter code and a collection of
  rake tasks to ease the management and deployment of your source code.

  Usage:
    bones -h/--help
    bones -v/--version
    bones command [options] [arguments]

  Examples:
    bones create new_project
    bones freeze -r git://github.com/fudgestudios/bort.git bort
    bones create -s bort new_rails_project

  Commands:
      MSG

     fmt = lambda { |cmd|
             if @plugins[cmd] < ::Bones::App::Command
               msg << "    bones %-15s %s\n" % [cmd, @plugins[cmd].summary]
             end
           }

     ary = [:create, :freeze, :unfreeze, :info, :plugins]
     ary.each(&fmt)
     (@plugins.keys - ary).each(&fmt)

      msg.concat <<-MSG

  Further Help:
    Each command has a '--help' option that will provide detailed
    information for that command.

    http://github.com/TwP/bones

      MSG

    stdout.puts msg
    end

  end  # class Main
end  # module Bones::App

# EOF
