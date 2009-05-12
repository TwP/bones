# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{bones}
  s.version = "2.5.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Tim Pease"]
  s.date = %q{2009-05-12}
  s.default_executable = %q{bones}
  s.description = %q{Mr Bones is a handy tool that builds a skeleton for your new Ruby projects. The skeleton contains some starter code and a collection of rake tasks to ease the management and deployment of your source code. Mr Bones is not viral -- all the code your project needs is included in the skeleton (no gem dependency required).}
  s.email = %q{tim.pease@gmail.com}
  s.executables = ["bones"]
  s.extra_rdoc_files = ["History.txt", "README.rdoc", "bin/bones", "lib/bones/tasks/ann.rake", "lib/bones/tasks/bones.rake", "lib/bones/tasks/gem.rake", "lib/bones/tasks/git.rake", "lib/bones/tasks/notes.rake", "lib/bones/tasks/post_load.rake", "lib/bones/tasks/rdoc.rake", "lib/bones/tasks/rubyforge.rake", "lib/bones/tasks/spec.rake", "lib/bones/tasks/svn.rake", "lib/bones/tasks/test.rake", "lib/bones/tasks/zentest.rake", "spec/data/foo/README.txt"]
  s.files = [".autotest", "History.txt", "README.rdoc", "Rakefile", "bin/bones", "data/.bnsignore", "data/History.txt.bns", "data/README.txt.bns", "data/Rakefile.bns", "data/bin/NAME.bns", "data/lib/NAME.rb.bns", "data/spec/NAME_spec.rb.bns", "data/spec/spec_helper.rb.bns", "data/test/test_NAME.rb", "lib/bones.rb", "lib/bones/annotation_extractor.rb", "lib/bones/app.rb", "lib/bones/app/command.rb", "lib/bones/app/create_command.rb", "lib/bones/app/file_manager.rb", "lib/bones/app/freeze_command.rb", "lib/bones/app/info_command.rb", "lib/bones/app/unfreeze_command.rb", "lib/bones/app/update_command.rb", "lib/bones/debug.rb", "lib/bones/smtp_tls.rb", "lib/bones/tasks/ann.rake", "lib/bones/tasks/bones.rake", "lib/bones/tasks/gem.rake", "lib/bones/tasks/git.rake", "lib/bones/tasks/notes.rake", "lib/bones/tasks/post_load.rake", "lib/bones/tasks/rdoc.rake", "lib/bones/tasks/rubyforge.rake", "lib/bones/tasks/setup.rb", "lib/bones/tasks/spec.rake", "lib/bones/tasks/svn.rake", "lib/bones/tasks/test.rake", "lib/bones/tasks/zentest.rake", "spec/bones/app/file_manager_spec.rb", "spec/bones/app_spec.rb", "spec/bones_spec.rb", "spec/data/data/.bnsignore", "spec/data/data/History", "spec/data/data/NAME/NAME.rb.bns", "spec/data/data/README.txt.bns", "spec/data/data/Rakefile.bns", "spec/data/data/lib/NAME.rb.bns", "spec/data/foo/README.txt", "spec/data/foo/Rakefile", "spec/spec_helper.rb"]
  s.has_rdoc = true
  s.homepage = %q{http://codeforpeople.rubyforge.org/bones}
  s.post_install_message = %q{--------------------------
 Keep rattlin' dem bones!
--------------------------
}
  s.rdoc_options = ["--main", "README.rdoc"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{codeforpeople}
  s.rubygems_version = %q{1.3.1}
  s.summary = %q{Mr Bones is a handy tool that builds a skeleton for your new Ruby projects}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<rake>, [">= 0.8.4"])
    else
      s.add_dependency(%q<rake>, [">= 0.8.4"])
    end
  else
    s.add_dependency(%q<rake>, [">= 0.8.4"])
  end
end
