Mr. Bones
    by Tim Pease
    FIX (url)

== DESCRIPTION:
  
FIX (describe your package)

== FEATURES/PROBLEMS:
  
* FIX (list of features or problems)

== SYNOPSIS:

  FIX (code sample of usage)

== REQUIREMENTS:

* FIX (list of requirements)

* rubyforge
* rcov
* spec

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
