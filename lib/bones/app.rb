
Main {
  program 'bones'
  version Bones::VERSION

  synopsis 'bones command [options] [arguments]'

  description <<-__
Mr Bones is a handy tool that builds a skeleton for your new Ruby
projects. The skeleton contains some starter code and a collection of
rake tasks to ease the management and deployment of your source code.

Usage:
  bones -h/--help
  bones command [options] [arguments]

Examples:
  bones create new_project
  bones freeze -r git://github.com/fudgestudios/bort.git bort
  bones create -s bort new_rails_project

Commands:
  bones create          create a new project from a skeleton
  bones freeze          create a new skeleton in ~/.mrbones/
  bones unfreeze        remove a skeleton from ~/.mrbones/
  bones info            show information about available skeletons

Further Help:
  Each command has a '--help' option that will provide detailed
  information for that command.

  http://gemcutter.org/gems/bones
  __

  def run() help!; end

  # --------------------------------------------------------------------------
  mode 'create' do
    synopsis 'bones create [options] <project_name>'
    description <<-__
Create a new project from a Mr Bones project skeleton. The skeleton can
be the default project skeleton from the Mr Bones gem or one of the named
skeletons found in the '~/.mrbones/' folder. A git or svn repository can
be used as the skeleton if the '--repository' flag is given.
    __

    argument('project_name') {
      arity 1
      description 'Name of the new Ruby project to create.'
    }

    option('d', 'directory') {
      argument :required
      description 'Project directory to create (defaults to project_name).'
    }

    option('s', 'skeleton') {
      argument :required
      description 'Project skeleton to use.'
    }

    option('r', 'repository') {
      argument :required
      description 'svn or git repository path.'
    }

    option('v', 'verbose') {
      description 'Enable verbose output.'
    }

    def run
      Bones::App::CreateCommand.run params
    end
  end

  # --------------------------------------------------------------------------
  mode 'freeze' do
    synopsis 'bones freeze [options] [skeleton_name]'
    description <<-__
Freeze the project skeleton to the current Mr Bones project skeleton.
If a name is not given, then the default name "data" will be used.
Optionally a git or svn repository can be frozen as the project
skeleton.
    __

    argument('skeleton_name') {
      arity 1
      default 'data'
      description 'Name of the skeleton to create.'
    }

    option('r', 'repository') {
      argument :required
      description 'svn or git repository path.'
    }

    option('v', 'verbose') {
      description 'Enable verbose output.'
    }

    def run
      Bones::App::FreezeCommand.run params
    end
  end

  # --------------------------------------------------------------------------
  mode 'unfreeze' do
    synopsis 'bones unfreeze [skeleton_name]'
    description <<-__
Removes the named skeleton from the '~/.mrbones/' folder. If a name is
not given then the default skeleton is removed.
    __

    argument('skeleton_name') {
      arity 1
      default 'data'
      description 'Name of the skeleton to remove.'
    }

    option('v', 'verbose') {
      description 'Enable verbose output.'
    }

    def run
      Bones::App::UnfreezeCommand.run params
    end
  end

  # --------------------------------------------------------------------------
  mode 'info' do
    synopsis 'bones info'
    description 'Shows information about available skeletons.'

    def run
      Bones::App::InfoCommand.run params
    end
  end
}


BEGIN {
  require 'main'
  require 'erb'

  module Bones::App; end

  begin
    $LOAD_PATH.unshift Bones.libpath
    require 'bones/app/command'
    require 'bones/app/file_manager'
    require 'bones/app/create_command'
    require 'bones/app/freeze_command'
    require 'bones/app/unfreeze_command'
    require 'bones/app/info_command'
  ensure
    $LOAD_PATH.shift
  end
}

# EOF
