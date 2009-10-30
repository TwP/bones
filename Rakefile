
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

  use_gmail
}

=begin
Bones.setup

PROJ.release_name = 'Maxilla'

PROJ.rubyforge.name = 'codeforpeople'

PROJ.rdoc.remote_dir = 'bones'
PROJ.rdoc.exclude << '^data/'
PROJ.notes.exclude = %w(^README\.txt$ ^data/ ^tasks/setup.rb$)

PROJ.spec.opts << '--color'

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
