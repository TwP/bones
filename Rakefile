
$:.unshift('lib')

require 'bones'

Bones {
  name         'bones'
  authors      'Tim Pease'
  email        'tim.pease@gmail.com'
  url          'http://gemcutter.org/gems/bones'
  version      Bones::VERSION
  ruby_opts    %w[-W0]
  readme_file  'README.rdoc'
  ignore_file  '.gitignore'

  depend_on 'little-plugger'
  depend_on 'loquacious'
  depend_on 'main'
  depend_on 'rake'
}

=begin
Bones.setup

PROJ.name = 'bones'
PROJ.authors = 'Tim Pease'
PROJ.email = 'tim.pease@gmail.com'
PROJ.url = 'http://codeforpeople.rubyforge.org/bones'
PROJ.version = Bones::VERSION
PROJ.release_name = 'Maxilla'
PROJ.ruby_opts = %w[-W0]
PROJ.readme_file = 'README.rdoc'
PROJ.ignore_file = '.gitignore'
PROJ.exclude << 'bones.gemspec'

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
PROJ.ann.text = PROJ.gem.extras[:post_install_message]

task :default => 'spec:specdoc'
task 'ann:prereqs' do
  PROJ.name = 'Mr Bones'
end

PROJ.gem.development_dependencies.clear

depend_on 'rake'
=end

# EOF
