
module Bones::Helpers
  extend self

  DEV_NULL = File.exist?('/dev/null') ? '/dev/null' : 'NUL:'
  SUDO = if system("which sudo > #{DEV_NULL} 2>&1") then 'sudo'
         else '' end unless defined? SUDO
  RCOV = "#{Bones::RUBY} -S rcov"
  RDOC = "#{Bones::RUBY} -S rdoc"
  GEM  = "#{Bones::RUBY} -S gem"
  HAVE_SVN = (Dir.entries(Dir.pwd).include?('.svn') and
              system("svn --version 2>&1 > #{DEV_NULL}"))

  HAVE = Hash.new(false)

  def have?( key, &block )
    return HAVE[key] if block.nil?
    HAVE[key] = block.call
  end

  def quiet( &block )
    io = [STDOUT.dup, STDERR.dup]
    STDOUT.reopen DEV_NULL
    STDERR.reopen DEV_NULL
    block.call
  ensure
    STDOUT.reopen io.first
    STDERR.reopen io.last
    io.each {|x| x.close}
  end

  # Reads the file located at the given +path+ and returns an array of the
  # desired +paragraphs+. The paragraphs can be given as a single section
  # +title+ or any number of paragraph numbers or ranges.
  #
  # For example:
  #
  #    changes = paragraphs_of('History.txt', 0..1).join("\n\n")
  #    summary, *description = paragraphs_of('README.md', 3, 3..8)
  #    features = paragraphs_of('README.md', 'features').join("\n\n")
  #    examples = paragraphs_of('README.md', 'examples').join("\n\n")
  #
  def paragraphs_of( path, *args )

    title = String === args.first ? args.shift : nil
    paragraphs = File.read(path).delete("\r").split(%r/\n\n+/)

    if title.nil? then
      result = paragraphs

    else
      title = Regexp.escape title
      start_rgxp = [%r/\A=+\s*#{title}/i, %r/\A#{title}\n[=-]+\s*\Z/i]
      end_rgxp   = [%r/\A=+/i, %r/\A.+\n[=-]+\s*\Z/i]

      result = []
      matching = false
      rgxp = start_rgxp

      paragraphs.each do |p|
        if rgxp.any? { |r| p =~ r }
          break if matching
          matching = true
          rgxp = end_rgxp
        elsif matching
          result << p
        end
      end
    end

    args.empty? ? result : result.values_at(*args)
  end

  # Find a rake task using the task name and remove any description text. This
  # will prevent the task from being displayed in the list of available tasks.
  #
  def remove_desc_for_task( names )
    Array(names).each do |task_name|
      task = Rake.application.tasks.find {|t| t.name == task_name}
      next if task.nil?
      task.instance_variable_set :@comment, nil
    end
  end

  # Given a list of filenames, return the first one that resolves to an
  # existing file on the filesystem. This allows us to specify a list of valid
  # files for the README and HISTORY files then pick the one that actually
  # exists on the user's filesystem.
  #
  def find_file( *args )
    args.each {|fn| return fn if test(?f, fn)}
    args.first
  end

end  # module Bones::Helpers

# We need a "valid" method thtat determines if a string is suitable for use
# in the gem specification.
#
class Object
  def valid?
    return !(self.empty? or self == "\000") if self.respond_to?(:to_str)
    return false
  end

  # Adds the given arguments to the include path if they are not already there
  #
  def ensure_in_path( *args )
    args.each do |path|
      path = File.expand_path(path)
      $:.unshift(path) if test(?d, path) and not $:.include?(path)
    end
  end
end

# EOF
