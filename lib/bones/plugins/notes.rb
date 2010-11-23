
module Bones::Plugins::Notes
  include ::Bones::Helpers
  extend self

  def initialize_notes
    ::Bones.config {
      desc 'Configuration for extracting annotations from project files.'
      notes {
        exclude [], :desc => <<-__
          A list of regular expression patterns that will be used to exclude
          certain files from the annotation search. Each pattern is given as a
          string, and they are all combined using the regular expression or
          "|" operator.
        __

        extensions %w[.txt .rb .erb .rdoc .md] << '', :desc => <<-__
          Only files with these extensions will be searched for annotations.
        __

        tags %w[FIXME OPTIMIZE TODO], :desc => <<-__
          The list of annotation tags that will be extracted from the files
          being searched.
        __
      }
    }

    have?(:notes) { true }
  end

  def define_tasks
    config = ::Bones.config

    desc "Enumerate all annotations"
    task :notes do |t|
      id = if t.application.top_level_tasks.length > 1
        t.application.top_level_tasks.slice!(1..-1).join(' ')
      end
      Bones::AnnotationExtractor.enumerate(
          config, config.notes.tags.join('|'), id, :tag => true)
    end

    namespace :notes do
      config.notes.tags.each do |tag|
        desc "Enumerate all #{tag} annotations"
        task tag.downcase.to_sym do |t|
          id = if t.application.top_level_tasks.length > 1
            t.application.top_level_tasks.slice!(1..-1).join(' ')
          end
          Bones::AnnotationExtractor.enumerate(config, tag, id)
        end
      end
    end
  end

end  # module Bones::Plugins::Notes

# EOF
