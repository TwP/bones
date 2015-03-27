
$:.unshift('lib')
require 'bones'

task :default => 'spec:run'
task 'gem:release' => 'spec:run'

begin gem('rspec', '~> 2.6'); rescue LoadError; end

Bones {
  name         'bones'
  authors      'Tim Pease'
  email        'tim.pease@gmail.com'
  url          'http://rubygems.org/gems/bones'

  spec.opts.concat %w[--color --format documentation]
  notes.exclude %w[^README\.rdoc$ ^data/]
  gem.extras[:post_install_message] = <<-MSG
--------------------------
 Keep rattlin' dem bones!
--------------------------
  MSG

  ann.paragraphs  %w[install synopsis features]
  ann.text        gem.extras[:post_install_message]

  use_gmail

  depend_on  'rake', '~> 10.0'
  depend_on  'rdoc', '~> 4.0'
  depend_on  'little-plugger', '~> 1.1'
  depend_on  'loquacious', '~> 1.9'

  depend_on  'rspec', '~> 3.2', :development => true

  # These are commented out to avoid circular dependencies when installing
  # bones-git or bones-rspec in development mode
  ####
  # depend_on  'bones-git',   :development => true
  # depend_on  'bones-rspec', :development => true
}

# don't want to depend on ourself
::Bones.config.gem._spec.dependencies.delete_if {|d| d.name == 'bones'}
