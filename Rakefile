# $Id$

$:.unshift('lib')

load 'tasks/setup.rb'
require 'bones'

task :default => 'spec:run'

PROJ.name = 'bones'
PROJ.authors = 'Tim Pease'
PROJ.email = 'tim.pease@gmail.com'
PROJ.url = 'http://codeforpeople.rubyforge.org/bones'
PROJ.rubyforge_name = 'codeforpeople'
PROJ.rdoc_remote_dir = 'bones'
PROJ.version = Bones::VERSION

PROJ.rdoc_exclude << '^data/'
PROJ.annotation_exclude = %w(^README\.txt$ ^data/ ^tasks/setup.rb$)
PROJ.svn = 'bones'

PROJ.spec_opts << '--color'

# EOF
