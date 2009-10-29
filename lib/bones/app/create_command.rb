
module Bones::App

class CreateCommand < Command

  def run
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

end  # class CreateCommand
end  # module Bones::App

# EOF
