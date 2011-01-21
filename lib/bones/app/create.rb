
module Bones::App
class Create < Command

  def self.initialize_create
    synopsis 'bones create [options] <project_name>'

    summary 'create a new project from a skeleton'

    description <<-__
Create a new project from a Mr Bones project skeleton. The skeleton can
be the default project skeleton from the Mr Bones gem or one of the named
skeletons found in the '~/.mrbones/' folder. A git or svn repository can
be used as the skeleton if the '--repository' flag is given.
    __

    option(standard_options[:directory])
    option(standard_options[:skeleton])
    option(standard_options[:repository])
    option(standard_options[:colorize])
  end

  def self.in_output_directory( *args )
    @in_output_directory ||= []
    @in_output_directory.concat(args.map {|str| str.to_sym})
    @in_output_directory
  end

  def run
    raise Error, "Output directory #{output_dir.inspect} already exists." if test ?e, output_dir

    copy_files
    announce

    in_directory(output_dir) {
      self.class.in_output_directory.each {|cmd| self.send cmd}
      fixme
    }
  end

  def parse( args )
    opts = super args

    config[:name] = args.empty? ? nil : args.join('_')
    config[:output_dir] = name if output_dir.nil?

    if name.nil?
      stdout.puts opts
      exit 1
    end
  end

  def copy_files
    fm = FileManager.new(
      :source => repository || skeleton_dir,
      :destination => output_dir,
      :stdout => stdout,
      :stderr => stderr,
      :verbose => true
    )
    fm.template name
  rescue Bones::App::FileManager::Error => err
    FileUtils.rm_rf output_dir
    msg = "Could not create '#{name}'"
    msg << " in directory '#{output_dir}'" if name != output_dir
    msg << "\n#{err.message}"
    raise Error, msg
  rescue Exception => err
    FileUtils.rm_rf output_dir
    msg = "Could not create '#{name}'"
    msg << " in directory '#{output_dir}'" if name != output_dir
    msg << "\n#{err.inspect}"
    raise Error, msg
  end

  def announce
    msg = "Created '#{name}'"
    msg << " in directory '#{output_dir}'" if name != output_dir
    stdout.puts msg
  end

  def fixme
    return unless test ?f, 'Rakefile'

    stdout.puts
    stdout.puts colorize('-'*31, :yellow)
    stdout.puts 'Now you need to fix these files'
    stdout.puts colorize('-'*31, :yellow)
    system "#{::Bones::RUBY} -S rake notes"
  end

end  # class Create
end  # module Bones::App

