Mr Bones
    by Tim Pease
    http://codeforpeople.rubyforge.org/bones

== DESCRIPTION:
  
Mr Bones is a handy tool tha builds a skeleton for your new Ruby projects. The
skelton contains some starter code and a collection of rake tasks to ease the
management and deployment of your source code. Mr Bones is not viral -- all the
code your project needs is included in the skelton (no gem dependency
required).

== FEATURES/PROBLEMS:

Mr Bones provides the following rake tasks; you are free to add your own:

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
  manifest:check       # Verify the manfiest
  manifest:create      # Create a new manifest
  spec:rcov            # Run all specs with RCov
  spec:run             # Run all specs with basic output
  spec:specdoc         # Run all specs with text output
  test:rcov            # Run rcov on the unit tests
  test:run             # Run tests for run

== SYNOPSIS:

To create a new "Get Fuzzy" project:

  bones get_fuzzy

If a new release of Mr Bones comes out with better features the "Get Fuzzy"
project will need to be updated:

  bones --update get_fuzzy

And if you ever get confused about what Mr Bones can do:

  bones --help

== REQUIREMENTS:

Mr Bones does not have any "requirements", but if you do not have the following
gems installed you will not get all that Mr Bones has to offer.

* rubyforge - for easy gem publishing to rubyforge.org
* rcov - for code coverage testing
* rspec - if that's the way you roll

== INSTALL:

* sudo gem install bones

== MANUAL:

Bag of rake tasks for easing the pain of project management. The tasks are controlled through options defined in the Rakefile. The tasks themselves are defined as '.rake' files in the tasks diectory.

Use a Manifest.txt to control which files are included in the gem

Use "depend_on" to declare dependencies

  depend_on 'rake', '0.8.1'

name = nil
summary = nil
description = nil
changes = nil
authors = nil
email = nil
url = nil
version = ENV['VERSION'] || '0.0.0'
rubyforge_name = nil
exclude = %w(tmp$ bak$ ~$ CVS \.svn)
extensions = FileList['ext/**/extconf.rb']
ruby_opts = %w(-w)
libs = []

RDoc Options

rdoc_opts = []
rdoc_include = %w(^lib ^bin ^ext txt$)
rdoc_exclude = %w(extconf\.rb$ ^Manifest\.txt$)
rdoc_main = 'README.txt'
rdoc_dir = 'doc'
rdoc_remote_dir = nil

Test::Unit Options

tests = FileList['test/**/test_*.rb']
test_file = 'test/all.rb'
test_opts = []

RSpec Options

specs = FileList['spec/**/*_spec.rb']
spec_opts = []

RCov Options

rcov_opts = ['--sort', 'coverage', '-T']

Gem Options

files = [] (from Manifest.txt)
executables = PROJ.files.find_all {|fn| fn =~ %r/^bin/}
dependencies = []
need_tar = true
need_zip = false

== LICENSE:

MIT License
Copyright (c) 2007 - 2008

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
'Software'), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
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
