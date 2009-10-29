
module Bones::App

class FreezeCommand < Command

  def run
    @options[:output_dir] = File.join(mrbones_dir, name)

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

    @out.puts "Project skeleton #{name.inspect} " <<
              "has been frozen to Mr Bones #{::Bones::VERSION}"
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
end  # module Bones::App

# EOF
