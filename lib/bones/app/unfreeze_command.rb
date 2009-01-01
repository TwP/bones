
module Bones
class App

class UnfreezeCommand < Command

  def run( args )
    parse args

    fm = FileManager.new(
      :source => repository || ::Bones.path('data'),
      :destination => output_dir,
      :stdout => @out,
      :stderr => @err,
      :verbose => verbose?
    )

    if fm.archive_destination
      @out.puts "Project skeleton #{name.inspect} has been unfrozen"
    else
      @out.puts "Project skeleton #{name.inspect} is not frozen " <<
                "(no action taken)"
    end
  end

  def parse( args )
    std_opts = standard_options

    opts = OptionParser.new
    opts.banner = 'Usage: bones unfreeze [skeleton_name]'

    opts.separator ''
    opts.separator "  Removes the named skeleton from the '~/.mrbones/' folder. If a name is"
    opts.separator "  not given then the default skeleton is removed."

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

end  # class UnfreezeCommand
end  # class App
end  # module Bones

# EOF
