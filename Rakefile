# $Id$

load 'tasks/setup.rb'

ensure_in_path 'lib'
require 'bones'

task :default => 'spec:run'

PROJ.name = 'bones'
PROJ.summary = ''
PROJ.authors = 'Tim Pease'
PROJ.email = 'tim.pease@gmail.com'
PROJ.url = 'http://bones.rubyforge.org/'
PROJ.description = paragraphs_of('README.txt', 3).join("\n\n")
PROJ.changes = paragraphs_of('History.txt', 0..1).join("\n\n")
PROJ.rubyforge_name = 'bones'
PROJ.version = Bones::VERSION

PROJ.exclude << '^doc'
PROJ.rdoc_exclude << '^data'

PROJ.spec_opts << '--color'

# EOF
