
module Bones::App

class InfoCommand < Command

  def run
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

end  # class InfoCommand
end  # module Bones::App

# EOF
