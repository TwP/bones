# -*- encoding: utf-8 -*-
# stub: bones 3.9.0 ruby lib

Gem::Specification.new do |s|
  s.name = "bones".freeze
  s.version = "3.9.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Tim Pease".freeze]
  s.date = "2022-05-27"
  s.description = "Mr Bones is a handy tool that creates new Ruby projects from a code\nskeleton. The skeleton contains some starter code and a collection of rake\ntasks to ease the management and deployment of your source code. Several Mr\nBones plugins are available for creating git repositories, creating GitHub\nprojects, running various test suites and source code analysis tools.".freeze
  s.email = "tim.pease@gmail.com".freeze
  s.executables = ["bones".freeze]
  s.extra_rdoc_files = ["History.txt".freeze, "README.rdoc".freeze, "bin/bones".freeze, "default/version.txt".freeze, "spec/data/markdown.txt".freeze, "spec/data/rdoc.txt".freeze]
  s.files = [".autotest".freeze, ".gitignore".freeze, "History.txt".freeze, "LICENSE".freeze, "README.rdoc".freeze, "Rakefile".freeze, "bin/bones".freeze, "default/.bnsignore".freeze, "default/History.txt.bns".freeze, "default/LICENSE.bns".freeze, "default/README.md.bns".freeze, "default/Rakefile.bns".freeze, "default/bin/NAME.bns".freeze, "default/lib/NAME.rb.bns".freeze, "default/spec/NAME_spec.rb.bns".freeze, "default/spec/spec_helper.rb.bns".freeze, "default/test/test_NAME.rb".freeze, "default/version.txt".freeze, "lib/bones.rb".freeze, "lib/bones/annotation_extractor.rb".freeze, "lib/bones/app.rb".freeze, "lib/bones/app/command.rb".freeze, "lib/bones/app/create.rb".freeze, "lib/bones/app/file_manager.rb".freeze, "lib/bones/app/freeze.rb".freeze, "lib/bones/app/info.rb".freeze, "lib/bones/app/plugins.rb".freeze, "lib/bones/app/unfreeze.rb".freeze, "lib/bones/colors.rb".freeze, "lib/bones/gem_package_task.rb".freeze, "lib/bones/helpers.rb".freeze, "lib/bones/plugins/ann.rb".freeze, "lib/bones/plugins/bones_plugin.rb".freeze, "lib/bones/plugins/gem.rb".freeze, "lib/bones/plugins/notes.rb".freeze, "lib/bones/plugins/rdoc.rb".freeze, "lib/bones/plugins/test.rb".freeze, "lib/bones/rake_override_task.rb".freeze, "script/bootstrap".freeze, "spec/bones/app/file_manager_spec.rb".freeze, "spec/bones/app_spec.rb".freeze, "spec/bones/helpers_spec.rb".freeze, "spec/bones_spec.rb".freeze, "spec/data/default/.bnsignore".freeze, "spec/data/default/.rvmrc.bns".freeze, "spec/data/default/History".freeze, "spec/data/default/NAME/NAME.rb.bns".freeze, "spec/data/default/README.md.bns".freeze, "spec/data/default/Rakefile.bns".freeze, "spec/data/default/bin/NAME.bns".freeze, "spec/data/default/lib/NAME.rb.bns".freeze, "spec/data/foo/README.md".freeze, "spec/data/foo/Rakefile".freeze, "spec/data/markdown.txt".freeze, "spec/data/rdoc.txt".freeze, "spec/spec_helper.rb".freeze, "version.txt".freeze]
  s.homepage = "http://rubygems.org/gems/bones".freeze
  s.licenses = ["MIT".freeze]
  s.post_install_message = "--------------------------\n Keep rattlin' dem bones!\n--------------------------\n".freeze
  s.rdoc_options = ["--main".freeze, "README.rdoc".freeze]
  s.rubygems_version = "3.1.2".freeze
  s.summary = "Mr Bones is a handy tool that creates new Ruby projects from a code skeleton.".freeze

  if s.respond_to? :specification_version then
    s.specification_version = 4
  end

  if s.respond_to? :add_runtime_dependency then
    s.add_runtime_dependency(%q<rake>.freeze, ["~> 13.0"])
    s.add_runtime_dependency(%q<rdoc>.freeze, ["~> 6.0"])
    s.add_runtime_dependency(%q<little-plugger>.freeze, ["~> 1.1"])
    s.add_runtime_dependency(%q<loquacious>.freeze, ["~> 1.9"])
    s.add_development_dependency(%q<rspec>.freeze, ["~> 3.5"])
  else
    s.add_dependency(%q<rake>.freeze, ["~> 13.0"])
    s.add_dependency(%q<rdoc>.freeze, ["~> 6.0"])
    s.add_dependency(%q<little-plugger>.freeze, ["~> 1.1"])
    s.add_dependency(%q<loquacious>.freeze, ["~> 1.9"])
    s.add_dependency(%q<rspec>.freeze, ["~> 3.5"])
  end
end
