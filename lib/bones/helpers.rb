
module Bones::Helpers

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

  # Reads a file at +path+ and spits out an array of the +paragraphs+
  # specified.
  #
  #    changes = paragraphs_of('History.txt', 0..1).join("\n\n")
  #    summary, *description = paragraphs_of('README.txt', 3, 3..8)
  #
  def paragraphs_of( path, *title_or_ranges )
    title = nil
    title ||= title_or_ranges.shift if String === title_or_ranges.first
    paragraphs_ranges = title_or_ranges
    paragraphs_ranges << (0..-1) if paragraphs_ranges.empty?

    paragraphs = File.read(path).delete("\r").split(/\n\n+/)

    if title.nil?
      found_paragraphs = paragraphs
    else
      found_paragraphs = []
      title_begin_regexp = [%r/^=+\s*#{Regexp.escape(title)}/i,
                            %r/^#{Regexp.escape(title)}\n[=-]+$/i]
      title_end_regexp = [%r/^=+/i,
                          %r/^.+\n[=-]+$/i]

      matching = false
      cur_regexp = title_begin_regexp
      paragraphs.each do |para|
        if cur_regexp.any? { |rxp| para =~ rxp }
          break if matching
          matching = true
          cur_regexp = title_end_regexp
        elsif matching
          found_paragraphs << para
        end
      end
    end

    found_paragraphs.values_at(*paragraphs_ranges)
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
