
module Bones
class App

class InfoCommand < Command

  def run( args )
    parse args

    skeleton_dir = File.join(mrbones_dir, 'data')
    skeleton_dir = ::Bones.path('data') unless test(?d, skeleton_dir)

    msg  = "\n"
    msg << "The default project skeleton will be copied from:\n"
    msg << "    " << skeleton_dir << "\n\n"

    fmt = "    %-12s => %s\n"
    msg << "Available projects skeletons are:\n"
    Dir.glob(File.join(mrbones_dir, '*')).sort.each do |fn|
      next if fn =~ %r/\.archive$/
      next if File.basename(fn) == 'data'

      if test(?f, fn)
        msg << fmt % [File.basename(fn), File.read(fn).strip]
      else
        msg << "    " << File.basename(fn) << "\n"
      end
    end

    @out.puts msg
    @out.puts
  end

  def parse( args )
    std_opts = standard_options

    opts = OptionParser.new
    opts.banner = 'Usage: bones info'

    opts.separator ''
    opts.separator '  Shows information about available skeletons'

    opts.separator ''
    opts.separator '  Common Options:'
    opts.on_tail( '-h', '--help', 'show this message' ) {
      @out.puts opts
      exit
    }

    # parse the command line arguments
    opts.parse! args
  end

end  # class InfoCommand
end  # class App
end  # module Bones

# EOF
