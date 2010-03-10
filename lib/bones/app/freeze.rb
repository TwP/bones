
module Bones::App
class Freeze < Command

  def self.initialize_freeze
    synopsis 'bones freeze [options] [skeleton_name]'

    summary 'create a new skeleton in ~/.mrbones/'

    description <<-__
Freeze the project skeleton to the current Mr Bones project skeleton.
If a name is not given, then the default name "default" will be used.
Optionally a git or svn repository can be frozen as the project
skeleton.
    __

    option(standard_options[:repository])
    option(standard_options[:verbose])
  end

  def run
    fm = FileManager.new(
      :source => repository || ::Bones.path(DEFAULT_SKELETON),
      :destination => output_dir,
      :stdout => stdout,
      :stderr => stderr,
      :verbose => verbose?
    )

    fm.archive_destination
    return freeze_to_repository if repository

    fm.copy

    stdout.puts "Project skeleton #{name.inspect} " <<
                "has been frozen to Mr Bones #{::Bones.version}"
  end

  def parse( args )
    opts = super args
    config[:name] = args.empty? ? DEFAULT_SKELETON : args.join('_')
    config[:output_dir] = File.join(mrbones_dir, name)
  end

  # Freeze the project skeleton to the git or svn repository that the user
  # passed in on the command line. This essentially creates an alias to the
  # reposiory using the name passed in on the command line.
  #
  def freeze_to_repository
    FileUtils.mkdir_p(File.dirname(output_dir))
    File.open(output_dir, 'w') {|fd| fd.puts repository}
    stdout.puts "Project skeleton #{name.inspect} " <<
                "has been frozen to #{repository.inspect}"
  end

end  # class Freeze
end  # module Bones::App

# EOF
