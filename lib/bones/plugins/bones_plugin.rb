
module Bones::Plugins::BonesPlugin
  include ::Bones::Helpers
  extend self

  module Syntax
    def enable_sudo
      use_sudo true
    end
  end

  def initialize_bones_plugin
    config = ::Bones.config {
      # ==== Project Defaults
      name  nil, :desc => <<-__
        The project name that will be used for packaging and distributing
        your Ruby code as a gem.
      __

      summary  nil, :desc => <<-__
        A short summary of your project. This summary is required in the
        gemspec, and it is used by the rubygem framework when searching
        for gems. If a summary is not given, then the first sentence from
        the project's README description is used as the summary.
      __

      description  nil, :desc => <<-__
        A longer description of your project. The description is used in
        the gemspec, but it is not required to build a gem. If a
        description is not given then the first paragraph from the
        project's README description is used as the description.
      __

      changes  nil, :desc => <<-__
        The list of notable changes in your project since the last release.
        The changes are automatically filled in by reading the list of
        changes from the project's History file. Only the changes for the
        most current release are included.
      __

      authors  nil, :desc => <<-__
        This can be a single author (as a string) or an array of authors
        if more than one person is working on the project.
      __

      email  nil, :desc => <<-__
        An email address so others can contact you with questions, bug
        reports, compliments, large quantities of cash, etc.
      __

      url  "\000", :desc => <<-__
        The canonical URL for your project. This should be a location
        where others can go to find out more information about the project
        such as links to source code, bug trackers, wikis, generated
        documentation, etc. A good recommendation would be to point
        to your gem on rubygems.org.
      __

      version  nil, :desc => <<-__
        Version number to use when creating the gem. This can be set either
        in the Rakefile or on the command line by setting the VERSION flag to
        the desired value.
        |
        |  rake gem VERSION=0.4.2
        |
        The VERSION flag must be explicitly set on the command line when
        releasing a gem. This is just a safety measure to prevent premature
        gem release.
      __

      release_name  ENV['RELEASE'], :desc => <<-__
        And optional release name to be associated with your gem. This is used
        only when creating a release announcement.
      __

      exclude  %w(tmp$ bak$ ~$ CVS \.svn/ ^\.git/ ^pkg/), :desc => <<-__
        A list of regular expression patterns that will be used to exclude
        certain files from the gem packaging process. Each pattern is given
        as a string, and they are all combined using the regular expression
        or "|" operator.
      __

      # ==== System Defaults
      ruby_opts  %w(-w), :desc => <<-__
        Default options to pass to the Ruby interpreter when executing tests
        and specs. The default is to enable all warnings. Since this is an
        array, the current options can be cleared and new options can be added
        using the standard array operations
        |
        |  ruby_opts.clear
        |  ruby_opts << '-Ilib' << '-rubygems'
        |
      __

      libs  Array.new, :desc => <<-__
        This is an array of directories to automatically include in the
        LOAD_PATH of your project. These directories are use for tests and
        specs, and the gem system sets the "require_paths" for the gem from
        these directories. If no libs are given, then the "lib" and "ext"
        directories are automatically added if they are present in your
        project.
      __

      history_file  nil, :desc => <<-__
        The name of your project's History file. The default is 'History.txt'
        but you are free to change it to whatever you choose.
      __

      readme_file  nil, :desc => <<-__
        The name of your project's README file. The default is 'README.md'
        but you are free to change it to whatever you choose. Since GitHub
        understand various markup languages, you can change the README
        file to support your markup language of choice.
      __

      ignore_file  nil, :desc => <<-__
        Mr Bones does not use a manifest to determine which fiels should be
        included in your project. All files are included unless they appear
        in the ignore file or in the "exclude" configruation option. The
        ignore file defaults to '.bnsignore'; however, if you are using git
        as your version control system you can just as easily set the ignore
        file to your '.gitignore' file.
      __

      colorize  true, :desc => <<-__
        When set to true, various output from Mr Bones will be colorized
        using terminal ANSI codes. Set to false if your terminal does not
        support colors.
      __

      use_sudo  false, :desc => <<-__
        When set to true gem commands will be run using sudo. A convenience
        method is provided to enable sudo for gem commands
        |
        |  enable_sudo
        |
        This is equivalent to 'use_sudo true', but it reads a little nicer.
      __
    }

    config.history_file = Proc.new { find_file(*%w[History.txt History HISTORY.txt HISTORY]) }
    config.ignore_file = Proc.new { find_file(*%w[.gitignore .bnsignore]) }
    config.readme_file = Proc.new { find_file(*%w[
        README.txt README.rdoc README.md README
        Readme.txt Readme.rdoc Readme.md Readme
    ]) }
  end

  def post_load
    config = ::Bones.config

    config.exclude << "^#{Regexp.escape(config.ignore_file)}$"
    config.changes     ||= paragraphs_of(config.history_file, 0..1).join("\n\n")
    config.description ||= paragraphs_of(config.readme_file, 'description').join("\n\n")
    if config.description.empty?
        config.description = paragraphs_of(config.readme_file, 1..1).first
    end
    config.summary ||= config.description[%r/^[^.]*\.?/]

    config.version ||= ENV['VERSION']
    if test(?f, 'version.txt') and !config.version
      config.version = File.read('version.txt').strip
    end
    config.version ||= '0.0.0'

    if config.libs.empty?
      %w(lib ext).each { |dir| config.libs << dir if test ?d, dir }
    end

    ::Bones::Helpers::SUDO.replace('') unless config.use_sudo
  end

  def define_tasks
    config = ::Bones.config

    namespace :bones do
      desc 'Show the current Mr Bones configuration'
      task :debug do |t|
        atr = if t.application.top_level_tasks.length == 2
          t.application.top_level_tasks.pop
        end

        ::Bones.help.show(atr, :descriptions => false, :values => true)
      end

      desc 'Show descriptions for the various Mr Bones configuration options'
      task :help do |t|
        atr = if t.application.top_level_tasks.length == 2
          t.application.top_level_tasks.pop
        end

        ::Bones.help.show(atr, :descriptions => true, :values => true)
      end

      desc 'Show the available Mr Bones configuration options'
      task :options do |t|
        atr = if t.application.top_level_tasks.length == 2
          t.application.top_level_tasks.pop
        end

        ::Bones.help.show(atr, :descriptions => false, :values => false)
      end

    end  # namespace :bones
  end

end  # module Bones::Plugins::BonesPlugin

# EOF
