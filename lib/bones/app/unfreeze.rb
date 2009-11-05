
module Bones::App
class Unfreeze < Command

  def self.initialize_unfreeze
    synopsis 'bones unfreeze [skeleton_name]'

    description <<-__
Removes the named skeleton from the '~/.mrbones/' folder. If a name is
not given then the default skeleton is removed.
    __

    option(standard_options[:verbose])
  end

  def run
    fm = FileManager.new(
      :source => repository || ::Bones.path('data'),
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
    config[:name] = args.empty? ? 'data' : args.join('_')
    config[:output_dir] = File.join(mrbones_dir, name)
  end

end  # class Unfreeze
end  # module Bones::App

# EOF
