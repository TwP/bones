Mr Bones
    by Tim Pease
    http://codeforpeople.rubyforge.org/bones

== DESCRIPTION:
  
Mr Bones is a handy tool that builds a skeleton for your new Ruby projects.
The skeleton contains some starter code and a collection of rake tasks to
ease the management and deployment of your source code. Mr Bones is not
viral -- all the code your project needs is included in the skeleton (no
gem dependency required).

== FEATURES/PROBLEMS:

Mr Bones provides the following rake tasks:

  clobber              # Remove all build products
  doc                  # Alias to doc:rdoc
  doc:rdoc             # Build the rdoc HTML Files
  doc:release          # Publish RDoc to RubyForge
  doc:rerdoc           # Force a rebuild of the RDOC files
  doc:ri               # Generate ri locally for testing
  gem                  # Alias to gem:package
  gem:debug            # Show information about the gem
  gem:gem              # Build the gem file
  gem:install          # Install the gem
  gem:package          # Build all the packages
  gem:release          # Package and upload to RubyForge
  gem:repackage        # Force a rebuild of the package files
  gem:uninstall        # Uninstall the gem
  manifest:check       # Verify the manifest
  manifest:create      # Create a new manifest
  notes                # Enumerate all annotations
  notes:fixme          # Enumerate all FIXME annotations
  notes:optimize       # Enumerate all OPTIMIZE annotations
  notes:todo           # Enumerate all TODO annotations
  spec:rcov            # Run all specs with RCov
  spec:run             # Run all specs with basic output
  spec:specdoc         # Run all specs with text output
  test:rcov            # Run rcov on the unit tests
  test:run             # Run tests for run

The rake tasks in the Mr Bones framework can be found in the "tasks"
directory. Add your own tasks there when you need more functionality.

== SYNOPSIS:

To create a new "Get Fuzzy" project:

  bones get_fuzzy

If a new release of Mr Bones comes out with better features the "Get Fuzzy"
project will need to be updated:

  bones --update get_fuzzy

And if you ever get confused about what Mr Bones can do:

  bones --help

== REQUIREMENTS:

Mr Bones does not have any "requirements", but if you do not have the
following gems installed you will not get all that Mr Bones has to offer.

* rubyforge - for easy gem publishing to rubyforge.org
* rcov - for code coverage testing
* rspec - if that's the way you roll
* rails - for source annotation extractor (notes)

== INSTALL:

* sudo gem install bones

== MANUAL:

The +bones+ command line tool is used to create a skeleton for a Ruby
project. In that skeleton is a "tasks" directory that contains the Mr Bones
rake files. These files are quite generic, and their functionality is
controlled by options configured in the top-level Rakefile. Take a look at
the Rakefile for the Mr Bones gem itself:

  load 'tasks/setup.rb'

  ensure_in_path 'lib'
  require 'bones'

  task :default => 'spec:run'

  PROJ.name = 'bones'
  PROJ.summary = 'Mr Bones is a handy tool that builds a skeleton for your new Ruby projects'
  PROJ.authors = 'Tim Pease'
  PROJ.email = 'not.real@fake.com'
  PROJ.url = 'http://codeforpeople.rubyforge.org/bones'
  PROJ.description = paragraphs_of('README.txt', 3).join("\n\n")
  PROJ.changes = paragraphs_of('History.txt', 0..1).join("\n\n")
  PROJ.rubyforge_name = 'codeforpeople'
  PROJ.rdoc_remote_dir = 'bones'
  PROJ.version = Bones::VERSION

  PROJ.exclude << '^doc'
  PROJ.rdoc_exclude << '^data'

  PROJ.spec_opts << '--color'

  # EOF

The +PROJ+ constant is an open struct that contains all the configuration
options for the project. The open struct is created in the "tasks/setup.rb"
file, and that is also where all the configurable options are defined. Take
a look in the "setup.rb" file to see what options are available, but always
make your changes in the Rakefile itself.

The Mr Bones rake system is based on a "Manifest.txt" file that contains a
list of all the files that will be used in the project. If a file does not
appear in the manifest, it will not be included in the gem. Use the
+manifest+ rake tasks to create and update the manifest as needed.

You can exclude files from being seen by the manifest -- the files are
invisible to the Mr Bones rake tasks. You would do this for any subversion
directories, backup files, or anything else you don't want gumming up the
works. The files to exclude are given as an array of regular expression
patterns.

  PROJ.exclude = %w(tmp$ bak$ ~$ CVS \.svn)
  PROJ.exclude << '^doc'

If your project depends on other gems, use the +depend_on+ command in your
Rakefile to declare the dependency. If you do not specify a version, the
most current version number for the installed gem is used.

  depend_on 'logging'
  depend_on 'rake', '0.7.3'

== LICENSE:

MIT License
Copyright (c) 2007 - 2008

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
'Software'), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sub-license, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
