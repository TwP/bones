
require 'fileutils'
require 'optparse'
require 'erb'

module Bones
class App

  # Create a new instance of App, and run the +bones+ application given
  # the command line _args_.
  #
  def self.run( args )
    self.new.run args
  end

  # Create a new main instance using _io_ for standard output and _err_ for
  # error messages.
  #
  def initialize( out = STDOUT, err = STDERR )
    @out = out
    @err = err
  end

  # Parse the desired user command and run that command object.
  #
  def run( args )
    cmd_str = args.shift
    cmd = case cmd_str
      when 'create';    CreateCommand.new(@out, @err)
      when 'update';    UpdateCommand.new(@out, @err)
      when 'freeze';    FreezeCommand.new(@out, @err)
      when 'unfreeze';  UnfreezeCommand.new(@out, @err)
      when 'info';      InfoCommand.new(@out, @err)
      when nil, '-h', '--help'
        help
      when '-v', '--version'
        @out.puts "Mr Bones #{::Bones::VERSION}"
        nil
      else
        raise "Unknown command #{cmd_str.inspect}"
      end

    cmd.run args if cmd

  rescue StandardError => err
    @err.puts "ERROR:  While executing bones ... (#{err.class})"
    @err.puts "    #{err.to_s}"
    exit 1
  end

  # Show the toplevel Mr Bones help message.
  #
  def help
    @out.puts <<-MSG

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
    bones create          create a new project from a skeleton
    bones update          copy Mr Bones tasks to a project
    bones freeze          create a new skeleton in ~/.mrbones/
    bones unfreeze        remove a skeleton from ~/.mrbones/
    bones info            show information about available skeletons

  Further Help:
    Each command has a '--help' option that will provide detailed
    information for that command.

    http://codeforpeople.rubyforge.org/bones/

    MSG
    nil
  end

end  # class App
end  # module Bones

Bones.require_all_libs_relative_to(__FILE__)

# EOF
