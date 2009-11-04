
module Bones::Plugins::Notes
  include ::Bones::Helpers
  extend self

  def initialize_notes
    ::Bones.config {
      notes {
        exclude  []
        extensions  %w(.txt .rb .erb .rdoc) << ''
        tags  %w(FIXME OPTIMIZE TODO)
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
