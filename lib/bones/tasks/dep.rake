
if PROJ.gem.dependencies.any? {|dep| dep.last.has_key? :alias}

namespace :dep do

  extconf = File.join %w{ext _dep extconf.rb}

  task :prereqs

  desc 'Create non-rubyforge dependency file'
  task :create => 'dep:prereqs' do
    mkdir_p(File.dirname(extconf)) unless test(?e, extconf)
    File.open(extconf,'w') {|fd| fd.puts %q{# automatically generated file}}
    PROJ.gem.dependencies.each do |dep|
      name, opts = dep
      next unless opts[:alias]

      cmd = "gem install "
      cmd << "--version '#{opts[:version].join(' ')}' " if opts.has_key?(:version)
      cmd << "--source #{opts[:source]} " if opts.has_key?(:source)
      cmd << opts[:alias]
      File.open(extconf, 'a+') {|fd| fd.puts "system \"#{cmd}\""}
    end
    File.open(extconf, 'a+') {|fd| fd.puts %q{File.open('Makefile','w') {|fd| fd.puts "install:\\n\\t@-echo -n ''"}}}
    PROJ.gem.files << extconf
  end

  desc 'Install any non-rubyforge dependencies'
  task :install => 'dep:create' do
    in_directory(File.dirname(extconf)) {ruby 'extconf.rb'}
  end


  desc 'Show information about non-rubyforge dependencies'
  task :debug => 'gem:prereqs' do
  end

  task :clobber do
    dir = File.dirname extconf
    rm_rf dir
  end

end  # namespace :dep


desc 'Alias to dep:create'
task :dep => 'dep:create'

task 'gem:prereqs' => 'dep:create'

task :clobber => 'dep:clobber'

end
# EOF
