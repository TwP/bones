
$:.unshift('lib')
require 'bones'

task :default => 'spec:run'
task 'gem:release' => 'spec:run'

Bones {
  name         'bones'
  authors      'Tim Pease'
  email        'tim.pease@gmail.com'
  url          'http://rubygems.org/gems/bones'
  ruby_opts    %w[-W0]

  spec.opts.concat %w[--color --format specdoc]
  notes.exclude %w[^README\.rdoc$ ^data/]
  gem.extras[:post_install_message] = <<-MSG
--------------------------
 Keep rattlin' dem bones!
--------------------------
  MSG

  ann.paragraphs  %w[install synopsis features]
  ann.text        gem.extras[:post_install_message]

  use_gmail

  depend_on  'rake'
  depend_on  'little-plugger'
  depend_on  'loquacious'

  depend_on  'rspec', :development => true
  depend_on  'bones-git', :development => true
  depend_on  'bones-rspec', :development => true
}

# don't want to depend on ourself
::Bones.config.gem._spec.dependencies.delete_if {|d| d.name == 'bones'}
