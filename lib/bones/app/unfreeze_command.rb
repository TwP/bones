
module Bones::App

class UnfreezeCommand < Command

  def run( args )
    @options[:output_dir] = File.join(mrbones_dir, name)

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

end  # class UnfreezeCommand
end  # module Bones::App

# EOF
