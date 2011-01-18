
module Bones::App
class Info < Command

  def self.initialize_info
    synopsis 'bones info'
    summary 'show information about available skeletons'
    description 'Shows information about available skeletons.'
  end

  def run
    skeleton_dir = File.join(mrbones_dir, DEFAULT_SKELETON)
    skeleton_dir = ::Bones.path(DEFAULT_SKELETON) unless test(?d, skeleton_dir)

    msg  = "\n"
    msg << "The default project skeleton will be copied from:\n"
    msg << "    " << colorize(skeleton_dir, :cyan) << "\n\n"

    fmt = "    #{colorize('%-12s', :green)} #{colorize('=>', :yellow)} #{colorize('%s', :cyan)}\n"
    msg << "Available projects skeletons are:\n"
    Dir.glob(File.join(mrbones_dir, '*')).sort.each do |fn|
      next if fn =~ %r/\.archive$/
      next if File.basename(fn) == DEFAULT_SKELETON

      if test(?f, fn)
        msg << fmt % [File.basename(fn), File.read(fn).strip]
      else
        msg << "    " << colorize(File.basename(fn), :green) << "\n"
      end
    end

    stdout.puts msg
    stdout.puts
  end

end  # class Info
end  # module Bones::App

# EOF
