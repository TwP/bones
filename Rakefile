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
PROJ.release_name = 'Agitated Beaver'

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

90% of New York City cab drivers are recently arrived immigrants.

== POST SCRIPT

Blessings,
TwP

#{PROJ.post_install_message}
ANN

task :default => 'spec:run'
task 'gem:package' => 'manifest:assert'
task(:titlize) {PROJ.name = 'Mr Bones'}
task 'ann:announcement' => :titlize

depend_on 'rake'

# EOF
