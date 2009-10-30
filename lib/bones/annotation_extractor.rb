
# A helper class used to find and display any annotations in a collection of
# project files.
#
class Bones::AnnotationExtractor

  Annotation = Struct.new(:line, :tag, :text) {
    # Returns a string representation of the annotation. If the
    # <tt>:tag</tt> parameter is given as +true+, then the annotation tag
    # will be included in the string.
    #
    def to_s( opts = {} )
      s = "[%3d] " % line
      s << "[#{tag}] " if opts[:tag]
      s << text
    end
  }

  # Enumerate all the annoations for the given _config_ and _tag_. This
  # will search for all athe annotations and display them on standard
  # output.
  #
  def self.enumerate( config, tag, id = nil, opts = {} )
    extractor = new(config, tag, id)
    extractor.display(extractor.find, opts)
  end

  attr_reader :tag, :config, :id

  # Creates a new annotation extractor configured to use the _config_ open
  # strcut and to search for the given _tag_ (which can be more than one tag
  # via a regular expression 'or' operation -- i.e. THIS|THAT|OTHER)
  #
  def initialize( config, tag, id) 
    @config = config
    @tag = tag
    @id = @id_rgxp = nil

    unless id.nil? or id.empty?
      @id = id
      @id_rgxp = Regexp.new(Regexp.escape(id), Regexp::IGNORECASE)
    end
  end

  # Iterate over all the files in the project and extract annotations from
  # the those files. Returns the results as a hash for display.
  #
  def find
    results = {}
    rgxp = %r/(#{tag}):?\s*(.*?)(?:\s*(?:-?%>|\*+\/))?$/o

    extensions = config.notes.extensions.dup
    exclude = if config.notes.exclude.empty? then nil
              else Regexp.new(config.notes.exclude.join('|')) end

    config.gem.files.each do |fn|
      next if exclude && exclude =~ fn
      next unless extensions.include? File.extname(fn)
      results.update(extract_annotations_from(fn, rgxp))
    end

    results
  end

  # Extract any annotations from the given _file_ using the regular
  # expression _pattern_ provided.
  #
  def extract_annotations_from( file, pattern )
    lineno = 0
    result = File.readlines(file).inject([]) do |list, line|
      lineno += 1
      next list unless m = pattern.match(line)
      next list << Annotation.new(lineno, m[1], m[2]) unless id

      text = m[2]
      if text =~ @id_rgxp
        text.gsub!(@id_rgxp) {|str| ::Bones::Colors.green(str)} if config.colorize
        list << Annotation.new(lineno, m[1], text)
      end
      list
    end
    result.empty? ? {} : { file => result }
  end

  # Print the results of the annotation extraction to the screen. If the
  # <tt>:tags</tt> option is set to +true+, then the annotation tag will be
  # displayed.
  #
  def display( results, opts = {} )
    results.keys.sort.each do |file|
      puts "#{file}:"
      results[file].each do |note|
        puts "  * #{note.to_s(opts)}"
      end
      puts
    end
  end

end  # class Bones::AnnotationExtractor

# EOF
