# $Id$

$:.unshift('lib')

load 'tasks/setup.rb'
require 'bones'

PROJ.name = 'bones'
PROJ.authors = 'Tim Pease'
PROJ.email = 'tim.pease@gmail.com'
PROJ.url = 'http://codeforpeople.rubyforge.org/bones'
PROJ.version = Bones::VERSION
PROJ.release_name = 'Haughty Hen'

PROJ.rubyforge.name = 'codeforpeople'

PROJ.rdoc.remote_dir = 'bones'
PROJ.rdoc.exclude << '^data/'
PROJ.notes.exclude = %w(^README\.txt$ ^data/ ^tasks/setup.rb$)
PROJ.svn.path = 'bones'

PROJ.spec.opts << '--color'

PROJ.ann.email[:server] = 'smtp.gmail.com'
PROJ.ann.email[:port] = 587

PROJ.gem.extras[:post_install_message] = <<-MSG
--------------------------
 Keep rattlin' dem bones!
--------------------------
MSG

PROJ.ann.paragraphs = %w[install synopsis features requirements]
PROJ.ann.text = <<-ANN
== FUN FACT

XML is much like violence --
if it's not solving your problem then you are not using enough of it.

== POST SCRIPT

Blessings,
TwP

#{PROJ.gem.extras[:post_install_message]}
ANN

task :default => 'spec:run'
task 'gem:package' => 'manifest:assert'
task 'ann:prereqs' do
  PROJ.name = 'Mr Bones'
end

depend_on 'rake'

# EOF
