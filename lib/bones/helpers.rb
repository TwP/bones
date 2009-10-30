
module Bones::Helpers
  DEV_NULL = File.exist?('/dev/null') ? '/dev/null' : 'NUL:'
  RUBY = ::Bones::RUBY

  DIFF = if system("gdiff '#{__FILE__}' '#{__FILE__}' > #{DEV_NULL} 2>&1") then 'gdiff'
         else 'diff' end unless defined? DIFF

  SUDO = if system("which sudo > #{DEV_NULL} 2>&1") then 'sudo'
         else '' end unless defined? SUDO

  RCOV = "#{RUBY} -S rcov"
  RDOC = "#{RUBY} -S rdoc"
  GEM  = "#{RUBY} -S gem"

  HAVE_SVN = (Dir.entries(Dir.pwd).include?('.svn') and
              system("svn --version 2>&1 > #{DEV_NULL}"))
  HAVE_GIT = (Dir.entries(Dir.pwd).include?('.git') and
              system("git --version 2>&1 > #{DEV_NULL}"))

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

  # Reads a file at +path+ and spits out an array of the +paragraphs+
  # specified.
  #
  #    changes = paragraphs_of('History.txt', 0..1).join("\n\n")
  #    summary, *description = paragraphs_of('README.txt', 3, 3..8)
  #
  def paragraphs_of( path, *paragraphs )
    title = String === paragraphs.first ? paragraphs.shift : nil
    ary = File.read(path).delete("\r").split(/\n\n+/)

    result = if title
      tmp, matching = [], false
      rgxp = %r/^=+\s*#{Regexp.escape(title)}/i
      paragraphs << (0..-1) if paragraphs.empty?

      ary.each do |val|
        if val =~ rgxp
          break if matching
          matching = true
          rgxp = %r/^=+/i
        elsif matching
          tmp << val
        end
      end
      tmp
    else ary end

    result.values_at(*paragraphs)
  end

  # Adds the given arguments to the include path if they are not already there
  #
  def ensure_in_path( *args )
    args.each do |path|
      path = File.expand_path(path)
      $:.unshift(path) if test(?d, path) and not $:.include?(path)
    end
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

  # Change working directories to _dir_, call the _block_ of code, and then
  # change back to the original working directory (the current directory when
  # this method was called).
  #
  def in_directory( dir, &block )
    curdir = pwd
    begin
      cd dir
      return block.call
    ensure
      cd curdir
    end
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
end

# This is merely a convenience method to remove methods from the Loquacious
# Configuration class. Rake adds lots of crap to the Kernel module, and this
# interferes with the configuration system.
#
def Loquacious.remove( *args )
  args.each { |name|
    name = name.to_s.delete('=')
    code = <<-__
      undef_method :#{name} rescue nil
      undef_method :#{name}= rescue nil
    __
    Loquacious::Configuration.module_eval code
    Loquacious::Configuration::DSL.module_eval code
  }
end

