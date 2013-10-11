
require 'find'
require 'rake/packagetask'
require 'rubygems/user_interaction'
if RUBY_VERSION >= "2"
  require 'rubygems/package'
else
  require 'rubygems/builder'
end

class Bones::GemPackageTask < Rake::PackageTask

  # Ruby GEM spec containing the metadata for this package.  The
  # name, version and package_files are automatically determined
  # from the GEM spec and don't need to be explicitly provided.
  #
  attr_accessor :gem_spec

  # Create a GEM Package task library.  Automatically define the gem
  # if a block is given.  If no block is supplied, then +define+
  # needs to be called to define the task.
  #
  def initialize(gem_spec)
    init(gem_spec)
    yield self if block_given?
    define if block_given?
  end

  # Initialization tasks without the "yield self" or define
  # operations.
  #
  def init(gem)
    super(gem.name, gem.version)
    @gem_spec = gem
    @package_files += gem_spec.files if gem_spec.files
  end

  # Create the Rake tasks and actions specified by this
  # GemPackageTask.  (+define+ is automatically called if a block is
  # given to +new+).
  #
  def define
    super
    task :prereqs
    task :package => ["#{package_dir_path}/#{gem_file}"]

    file "#{package_dir_path}/#{gem_file}" => [package_dir_path] + package_files do
      when_writing("Creating GEM") {
        chdir(package_dir_path) do
          Gem::Builder.new(gem_spec).build
          verbose(true) {
            mv gem_file, "../#{gem_file}"
          }
        end
      }
    end

    file package_dir_path => 'gem:prereqs' do
      mkdir_p package_dir rescue nil
    end
  end

  #
  #
  def gem_file
    if @gem_spec.platform == Gem::Platform::RUBY
      "#{package_name}.gem"
    else
      "#{package_name}-#{@gem_spec.platform}.gem"
    end
  end

end  # class Bones::GemPackageTask

# EOF
