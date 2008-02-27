# $Id$

$:.unshift('lib')

load 'tasks/setup.rb'
require 'bones'

PROJ.name = 'bones'
PROJ.authors = 'Tim Pease'
PROJ.email = 'tim.pease@gmail.com'
PROJ.url = 'http://codeforpeople.rubyforge.org/bones'
PROJ.rubyforge_name = 'codeforpeople'
PROJ.rdoc_remote_dir = 'bones'
PROJ.version = Bones::VERSION
PROJ.release_name = 'Finite State Puppy'

PROJ.rdoc_exclude << '^data/'
PROJ.annotation_exclude = %w(^README\.txt$ ^data/ ^tasks/setup.rb$)
PROJ.svn = 'bones'

PROJ.spec_opts << '--color'

PROJ.ann_email[:server] = 'smtp.gmail.com'
PROJ.ann_email[:port] = 587

PROJ.post_install_message = <<-MSG
--------------------------
 Keep rattlin' dem bones!
--------------------------
MSG

PROJ.ann_paragraphs = %w[install synopsis features requirements]
PROJ.ann_text = <<-ANN
== FUN FACT

A 'jiffy' is an actual unit of time for 1/100th of a second.

== POST SCRIPT

Blessings,
TwP

== POST POST SCRIPT

The "Finite State Puppy" is the only known pet that is Touring complete.

#{PROJ.post_install_message}
ANN

task :default => 'spec:run'
task 'gem:package' => 'manifest:assert'
task(:titlize) {PROJ.name = 'Mr Bones'}
task 'ann:announcement' => :titlize

depend_on 'rake'

# EOF
