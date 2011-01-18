
module Bones::App
class Unfreeze < Command

  def self.initialize_unfreeze
    synopsis 'bones unfreeze [skeleton_name]'

    summary 'remove a skeleton from ~/.mrbones/'

    description <<-__
Removes the named skeleton from the '~/.mrbones/' folder. If a name is
not given then the default skeleton is removed.
    __

    option(standard_options[:verbose])
    option(standard_options[:colorize])
  end

  def run
    fm = FileManager.new(
      :source => repository || ::Bones.path(DEFAULT_SKELETON),
      :destination => output_dir,
      :stdout => stdout,
      :stderr => stderr,
      :verbose => verbose?
    )

    if fm.archive_destination
      stdout.puts "Project skeleton #{name.inspect} has been unfrozen"
    else
      stdout.puts "Project skeleton #{name.inspect} is not frozen " <<
                  "(no action taken)"
    end
  end

  def parse( args )
    opts = super args
    config[:name] = args.empty? ? DEFAULT_SKELETON : args.join('_')
    config[:output_dir] = File.join(mrbones_dir, name)
  end

end  # class Unfreeze
end  # module Bones::App

# EOF
