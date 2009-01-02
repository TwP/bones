
$:.unshift('lib')

require 'bones'
Bones.setup

PROJ.name = 'bones'
PROJ.authors = 'Tim Pease'
PROJ.email = 'tim.pease@gmail.com'
PROJ.url = 'http://codeforpeople.rubyforge.org/bones'
PROJ.version = Bones::VERSION
PROJ.release_name = 'Distal Phalanges'
PROJ.ruby_opts = %w[-W0]
PROJ.readme_file = 'README.rdoc'

PROJ.rubyforge.name = 'codeforpeople'

PROJ.rdoc.remote_dir = 'bones'
PROJ.rdoc.exclude << '^data/'
PROJ.notes.exclude = %w(^README\.txt$ ^data/ ^tasks/setup.rb$)

PROJ.spec.opts << '--color'

PROJ.ann.email[:server] = 'smtp.gmail.com'
PROJ.ann.email[:port] = 587
PROJ.ann.email[:from] = 'Tim Pease'

PROJ.gem.extras[:post_install_message] = <<-MSG
--------------------------
 Keep rattlin' dem bones!
--------------------------
MSG

PROJ.ann.paragraphs = %w[install synopsis features requirements]
PROJ.ann.text = <<-ANN
== FUN FACT

"Tom Sawyer" was the first novel written on a typewriter.

== POST SCRIPT

Blessings,
TwP

#{PROJ.gem.extras[:post_install_message]}
ANN

task :default => 'spec:specdoc'
task 'gem:package' => 'manifest:assert'
task 'ann:prereqs' do
  PROJ.name = 'Mr Bones'
end

PROJ.gem.development_dependencies.clear

depend_on 'rake'

# EOF
