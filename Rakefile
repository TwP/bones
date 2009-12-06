
$:.unshift('lib')
require 'bones'

task :default => 'spec:specdoc'
task 'gem:release' => 'spec:run'

Bones {
  name         'bones'
  authors      'Tim Pease'
  email        'tim.pease@gmail.com'
  url          'http://gemcutter.org/gems/bones'
  version      Bones::VERSION
  ruby_opts    %w[-W0]
  readme_file  'README.rdoc'
  ignore_file  '.gitignore'
  rubyforge.name 'codeforpeople'

  spec.opts << '--color'
  notes.exclude %w[^README\.rdoc$ ^data/]
  gem.extras[:post_install_message] = <<-MSG
--------------------------
 Keep rattlin' dem bones!
--------------------------
  MSG

  ann.paragraphs  %w[install synopsis features]
  ann.text        gem.extras[:post_install_message]

  use_gmail
  enable_sudo

  depend_on  'rake'
  depend_on  'little-plugger'
  depend_on  'loquacious'

  gem.development_dependencies.clear
  depend_on  'rspec', :development => true
  depend_on  'bones-git', :development => true
  depend_on  'bones-extras', :development => true
}
