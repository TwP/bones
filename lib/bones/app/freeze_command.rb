
module Bones
class App

class FreezeCommand < Command

  def run( args )
    parse args

    fm = FileManager.new(
      :source => repository || ::Bones.path('data'),
      :destination => output_dir,
      :stdout => @out,
      :stderr => @err,
      :verbose => verbose?
    )

    fm.archive_destination
    return freeze_to_repository if repository

    fm.copy
    copy_tasks(File.join(output_dir, 'tasks')) if with_tasks?

    @out.puts "Project skeleton #{name.inspect} " <<
              "has been frozen to Mr Bones #{::Bones::VERSION}"
  end

  def parse( args )
    std_opts = standard_options

    opts = OptionParser.new
    opts.banner = 'Usage: bones freeze [options] [skeleton_name]'

    opts.separator ''
    opts.separator '  Freeze the project skeleton to the current Mr Bones project skeleton.'
    opts.separator '  If a name is not given, then the default name "data" will be used.'
    opts.separator '  Optionally a git or svn repository can be frozen as the project'
    opts.separator '  skeleton.'

    opts.separator ''
    opts.on(*std_opts[:repository])
    opts.on(*std_opts[:with_tasks])

    opts.separator ''
    opts.separator '  Common Options:'
    opts.on_tail( '-h', '--help', 'show this message' ) {
      @out.puts opts
      exit
    }

    # parse the command line arguments
    opts.parse! args
    options[:name] = args.empty? ? 'data' : args.join('_')
    options[:output_dir] = File.join(mrbones_dir, name)
  end

  # Freeze the project skeleton to the git or svn repository that the user
  # passed in on the command line. This essentially creates an alias to the
  # reposiory using the name passed in on the command line.
  #
  def freeze_to_repository
    FileUtils.mkdir_p(File.dirname(output_dir))
    File.open(output_dir, 'w') {|fd| fd.puts repository}
    @out.puts "Project skeleton #{name.inspect} " <<
              "has been frozen to #{repository.inspect}"
  end


end  # class FreezeCommand
end  # class App
end  # module Bones

# EOF
