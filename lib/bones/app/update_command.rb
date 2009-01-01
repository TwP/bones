
module Bones
class App

class UpdateCommand < Command

  def run( args )
    parse args

    raise "'#{output_dir}' does not exist" unless test(?e, output_dir)
    copy_tasks(File.join(output_dir, 'tasks'))

    msg = "Updated tasks in directory '#{output_dir}'"
    @out.puts msg
  end

  def parse( args )
    std_opts = standard_options

    opts = OptionParser.new
    opts.banner = 'Usage: bones update <directory>'

    opts.separator ''
    opts.separator '  Copy the Mr Bones rake tasks into the project directory'

    opts.separator ''
    opts.separator '  Common Options:'
    opts.on_tail( '-h', '--help', 'show this message' ) {
      @out.puts opts
      exit
    }

    # parse the command line arguments
    opts.parse! args
    options[:output_dir] = args.empty? ? nil : args.join('_')

    if output_dir.nil?
      @out.puts opts
      exit 1
    end
  end

end  # class CreateCommand
end  # class App
end  # module Bones

# EOF
