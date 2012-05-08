
require 'rubygems/dependency_installer'

module Bones::Plugins::Gem
  include ::Bones::Helpers
  extend self

  GemspecError = Class.new(StandardError)

  module Syntax
    # Adds the given gem _name_ to the current project's dependency list. An
    # optional gem _version_ can be given. If omitted, the newest gem version
    # will be used.
    #
    def depend_on( name, *args )
      opts = Hash === args.last ? args.pop : {}
      version = args.first || opts[:version]
      development = opts.key?(:development) ? opts[:development] : opts.key?(:dev) ? opts[:dev] : false

      spec = nil
      if Gem::Specification.respond_to? :find_by_name
        begin
          spec = Gem::Specification.find_by_name(name)
        rescue Gem::LoadError => err
        end
      else
        spec = Gem.source_index.find_name(name).last
      end

      version = ">= #{spec.version.to_s}" if version.nil? and !spec.nil?

      dep = case version
            when nil; [name]
            when %r/^\d/; [name, "= #{version}"]
            else [name, version] end

      development ?
          ::Bones.config.gem.development_dependencies << dep :
          ::Bones.config.gem.dependencies << dep
      nil
    end

    # Add the given _url_ to the list of gem sources.
    #
    def source( url )
      sources = ::Bones.config.gem.sources
      sources << url unless sources.include? url
      nil
    end
  end

  def initialize_gem
    Gem.configuration

    ::Bones.config {
      desc 'Configuration settings for gem packaging.'
      gem {
        dependencies  Array.new, :desc => <<-__
          Array of gem dependencies.

          A convenience method is provided to add gem dependencies, and so you
          should not muck about with this configuration setting manually.

          |  depend_on 'rake'
          |  depend_on 'rspec', '1.2.8'    # expands to '= 1.2.8'
          |  depend_on 'main', '~> 2.0'
        __

        development_dependencies  Array.new, :desc => <<-__
          Array of development gem dependencies.

          A convenience method is provided to add gem dependencies, and so you
          should not muck about with this configuration setting manually.

          |  depend_on 'bones', :development => true
          |  depend_on 'mocha', :version => '0.9.8', :development => true
        __

        executables  nil, :desc => <<-__
          Array of executables provided by your project. All files in the 'bin'
          folder will be included by default. However, if you are using a
          non-standard location for your executables then you will need to
          include them explicitly here as an Array.
        __

        extensions  FileList['ext/**/extconf.rb'], :desc => <<-__
          Array of gem extensions. This is the list of 'extconf.rb' files
          provided by your project. Rubygems uses this list of files to
          compile extensions when installing your gem.
        __

        files  nil, :desc => <<-__
          The list of files to include when packaging up your gem. This
          defaults to all files in the current directory excluding those
          matched by the 'exclude' option and the 'ignore_file'. You can
          supply your Array of files if you desire.
        __

        need_tar  true, :desc => <<-__
          When set to true a tar-gzip file will be produced along with your
          gem. The default is true.
        __

        need_zip  false, :desc => <<-__
          When set to true a zip file will be produced along with your gem.
          The default is false.
        __

        extras  Hash.new, :desc => <<-__
          A hash of extra Gem::Specification settings that are otherwise not
          provided for by Mr Bones. You will need to refer to the rubygems
          documentation for a complete list of specification settings.
        __

        sources  Gem.sources.dup, :desc => <<-__
          An array of sources to fetch remote gems from. A convenience method
          is provided to add new gem sources to this list.

          |  source 'http://gems.example.com'
          |  source 'http://rubygems.org'
        __
      }
    }

    have?(:gem) { true }
  end

  def post_load
    config = ::Bones.config

    Gem.sources = config.gem.sources

    unless $bones_external_spec
      config.gem.files ||= manifest
      config.gem.executables ||= config.gem.files.find_all {|fn| fn =~ %r/^bin/}
      config.gem.development_dependencies << ['bones', ">= #{Bones.version}"]
    end
  end

  def define_tasks
    config = ::Bones.config

    namespace :gem do
      if config.gem._spec.nil?
        config.gem._spec = Gem::Specification.new do |s|
          s.name = config.name
          s.version = config.version
          s.summary = config.summary
          s.authors = Array(config.authors)
          s.email = config.email
          s.homepage = Array(config.url).first
          s.rubyforge_project = config.name

          if !config.rubyforge.nil? and config.rubyforge.name
            s.rubyforge_project = config.rubyforge.name
          end

          s.description = config.description

          config.gem.dependencies.each do |dep|
            s.add_dependency(*dep)
          end

          config.gem.development_dependencies.each do |dep|
            s.add_development_dependency(*dep)
          end

          s.files = config.gem.files
          s.executables = config.gem.executables.map {|fn| File.basename(fn)}
          s.extensions = config.gem.files.grep %r/extconf\.rb$/

          s.bindir = 'bin'
          dirs = Dir["{#{config.libs.join(',')}}"]
          s.require_paths = dirs unless dirs.empty?

          if have? :rdoc
            incl = Regexp.new(config.rdoc.include.join('|'))
            excl = config.rdoc.exclude.dup.concat %w[\.rb$ ^(\.\/|\/)?ext]
            excl = Regexp.new(excl.join('|'))
            rdoc_files = config.gem.files.find_all do |fn|
                           case fn
                           when excl; false
                           when incl; true
                           else false end
                         end
            s.rdoc_options = config.rdoc.opts + ['--main', config.rdoc.main]
            s.extra_rdoc_files = rdoc_files
          end

          if config.test
            if test ?f, config.test.file
              s.test_file = config.test.file
            else
              s.test_files = config.test.files.to_a
            end
          end

          # Do any extra stuff the user wants
          config.gem.extras.each do |msg, val|
            case val
            when Proc
              val.call(s.send(msg))
            else
              s.send "#{msg}=", val
            end
          end
        end  # Gem::Specification.new
      end  # if gem._spec.nil?

      ::Bones::GemPackageTask.new(config.gem._spec) do |pkg|
        pkg.need_tar = config.gem.need_tar
        pkg.need_zip = config.gem.need_zip
      end

      desc 'Package and upload to rubygems.org'
      task :release => [:clobber, 'gem'] do |t|
        v = ENV['VERSION'] or abort 'Must supply VERSION=x.y.z'
        abort "Versions don't match #{v} vs #{config.version}" if v != config.version

        Dir.glob("pkg/#{config.gem._spec.full_name}*.gem").each { |fn|
          sh "#{GEM} push #{fn}"
        }
      end

      desc 'Show information about the gem'
      task :debug => 'gem:prereqs' do
        puts config.gem._spec.to_ruby
      end

      # don't use the "spec" task if we have an external gemspec
      unless $bones_external_spec
        desc 'Write the gemspec'
        task :spec => 'gem:prereqs' do
          File.open("#{config.name}.gemspec", 'w') do |f|
            f.write config.gem._spec.to_ruby
          end
        end
      end

      desc 'Write the gemspec in Rails YAML format'
      task :rails_spec => 'gem:prereqs' do
        File.open('.specification', 'w') do |f|
          f.write config.gem._spec.to_yaml
        end
      end

      desc 'Install the gem'
      task :install => [:clobber, 'gem:package'] do
        sh "#{SUDO} #{GEM} install pkg/#{config.gem._spec.full_name}"

        # use this version of the command for rubygems > 1.0.0
        #sh "#{SUDO} #{GEM} install --no-update-sources pkg/#{config.gem._spec.full_name}"
      end

      desc 'Uninstall the gem'
      task :uninstall do
        # FIXME: check for rubygems version 1.8.X
        installed_list = Gem::Specification.respond_to?(:find_all_by_name) ?
            Gem::Specification.find_all_by_name(config.name) :
            Gem.source_index.find_name(config.name)

        if installed_list and installed_list.collect { |s| s.version.to_s}.include?(config.version) then
          sh "#{SUDO} #{GEM} uninstall --version '#{config.version}' --ignore-dependencies --executables #{config.name}"
        end
      end

      desc 'Reinstall the gem'
      task :reinstall => [:uninstall, :install]

      desc 'Cleanup the gem'
      task :cleanup do
        sh "#{SUDO} #{GEM} cleanup #{config.gem._spec.name}"
      end

      desc 'Install gem dependencies'
      task :install_dependencies => 'gem:prereqs' do
        installer = Gem::DependencyInstaller.new
        config.gem._spec.dependencies.each {|dep|
          # FIXME: check for rubygems version 1.8.X
          if dep.respond_to? :matching_specs
            next unless dep.matching_specs(true).empty?
          else
            next if Gem.available? dep
          end

          $stdout.puts "Installing #{dep.name}"
          begin
            installer.install dep
          rescue
            $stdout.puts('  '+Bones::Colors.colorize("Could not install #{dep.name}!", :white, :on_red))
            $stdout.puts('  '+Bones::Colors.colorize("The gem does not appear to exist in any known repository.", :cyan))
            next
          end
          installer.installed_gems.each {|spec|
            $stdout.puts "Successfully installed #{spec.full_name}"
          }
        }
      end
    end  # namespace :gem

    desc 'Alias to gem:package'
    task :gem => 'gem:package'

    task :clobber => 'gem:clobber_package'
    remove_desc_for_task 'gem:clobber_package'
  end

  # Scans the current working directory and creates a list of files that are
  # candidates to be in the manifest.
  #
  def manifest
    config = ::Bones.config
    files = []
    exclude = config.exclude.dup
    comment = %r/^\s*#/

    # process the ignore file and add the items there to the exclude list
    if test(?f, config.ignore_file)
      ary = []
      File.readlines(config.ignore_file).each do |line|
        next if line =~ comment
        line.chomp!
        line.strip!
        next if line.nil? or line.empty?

        glob = line =~ %r/\*\./ ? File.join('**', line) : line
        Dir.glob(glob).each {|fn| ary << "^#{Regexp.escape(fn)}"}
      end
      exclude.concat ary
    end

    # generate a regular expression from the exclude list
    exclude = Regexp.new(exclude.join('|'))

    Find.find '.' do |path|
      path.sub! %r/^(\.\/|\/)/o, ''
      next unless test ?f, path
      next if path =~ exclude
      files << path
    end
    files.sort!
  end

  # Import configuration from the given gemspec file.
  #
  def import_gemspec( filename )
    $bones_external_spec = false
    spec = load_gemspec(filename)
    return if spec.nil?

    config = ::Bones.config
    config.gem._spec = spec
    $bones_external_spec = true

    config.name               = spec.name
    config.version            = spec.version
    config.summary            = spec.summary
    config.authors            = spec.authors
    config.email              = spec.email
    config.url                = spec.homepage
    config.description        = spec.description
    config.files              = spec.files
    config.libs               = spec.require_paths
    config.rubyforge_project  = spec.rubyforge_project

    config.gem.executables    = spec.executables
    config.rdoc.opts          = spec.rdoc_options
    config.test.file          = spec.test_file if spec.test_file
    config.test.files         = spec.test_files if spec.test_files

    spec.runtime_dependencies.each do |dep|
      config.gem.dependencies << [dep.name, dep.requirements_list].flatten
    end

    spec.development_dependencies.each do |dep|
      config.gem.development_dependencies << [dep.name, dep.requirements_list].flatten
    end

    [:signing_key, :cert_chain, :post_install_message, :licenses].each { |key|
      value = spec.send(key)
      next if value.nil? or value.empty?
      config.gem.extras[key] = value
    }

    nil
  end

  # This method is stolen from the Bundler gem. It loads the gemspec from a
  # file if available.
  #
  def load_gemspec( filename )
    path = Pathname.new(filename)
    # Eval the gemspec from its parent directory
    Dir.chdir(path.dirname) do
      begin
        Gem::Specification.from_yaml(path.basename)
        # Raises ArgumentError if the file is not valid YAML
      rescue ArgumentError, SyntaxError, Gem::EndOfYAMLException, Gem::Exception
        begin
          eval(File.read(path.basename), TOPLEVEL_BINDING, path.expand_path.to_s)
        rescue LoadError => e
          original_line = e.backtrace.find { |line| line.include?(path.to_s) }
          msg  = "There was a LoadError while evaluating #{path.basename}:\n  #{e.message}"
          msg << " from\n  #{original_line}" if original_line
          msg << "\n"

          if RUBY_VERSION >= "1.9.0"
            msg << "\nDoes it try to require a relative path? That doesn't work in Ruby 1.9."
          end

          raise GemspecError, msg
        end
      end
    end
  end

end  # Bones::Plugins::Gem

