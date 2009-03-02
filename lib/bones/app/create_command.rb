
module Bones
class App

class CreateCommand < Command

  def run( args )
    parse args

    fm = FileManager.new(
      :source => repository || skeleton_dir,
      :destination => output_dir,
      :stdout => @out,
      :stderr => @err,
      :verbose => verbose?
    )
    raise "Output directory already exists #{output_dir.inspect}" if test(?e, fm.destination)

    begin
      fm.copy
      copy_tasks(File.join(output_dir, 'tasks')) if with_tasks?
      fm.finalize name

      pwd = File.expand_path(FileUtils.pwd)
      msg = "Created '#{name}'"
      msg << " in directory '#{output_dir}'" if name != output_dir
      @out.puts msg

      if test(?f, File.join(output_dir, 'Rakefile'))
        begin
          FileUtils.cd output_dir
          @out.puts "Now you need to fix these files"
          system "#{::Bones::RUBY} -S rake notes"
        ensure
          FileUtils.cd pwd
        end
      end
    rescue Exception => err
      FileUtils.rm_rf output_dir
      msg = "Could not create '#{name}'"
      msg << " in directory '#{output_dir}'" if name != output_dir
      raise msg
    end
  end

  def parse( args )
    std_opts = standard_options

    opts = OptionParser.new
    opts.banner = 'Usage: bones create [options] <project_name>'

    opts.separator ''
    opts.separator "  Create a new project from a Mr Bones project skeleton. The skeleton can"
    opts.separator "  be the default project skeleton from the Mr Bones gem or one of the named"
    opts.separator "  skeletons found in the '~/.mrbones/' folder. A git or svn repository can"
    opts.separator "  be used as the skeleton if the '--repository' flag is given."

    opts.separator ''
    opts.on(*std_opts[:directory])
    opts.on(*std_opts[:skeleton])
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
    options[:name] = args.empty? ? nil : args.join('_')

    if name.nil?
      @out.puts opts
      exit 1
    end
    options[:output_dir] = name if output_dir.nil?
  end

end  # class CreateCommand
end  # class App
end  # module Bones

# EOF
