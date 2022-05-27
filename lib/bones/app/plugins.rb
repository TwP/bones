
module Bones::App
  class Plugins < Command

    def self.initialize_plugins
      synopsis 'bones plugins [options]'

      summary 'list available Mr Bones plugins'

      description <<-__
Parse the installed gems and then search for Mr Bones plugins related to
those gems. Passing in the 'all' flag will show plugins even if the related
gems are not installed.
      __

      option('-a', '--all', 'Show all plugins.', lambda { |_| config[:all] = true })
      option(standard_options[:colorize])
    end

    def run
      stdout.write 'Looking up avaialble Mr Bones plugins ... '
      stdout.flush
      plugins = find_bones_plugins
      stdout.puts 'done!'
      stdout.puts

      if all?
        plugins.each {|name, version| show_plugin(name, version)}
      else
        gemspecs = find_gemspecs
        plugins.each { |name, version|
          gemspecs.each { |gem_name, gem_version|
            next unless name.downcase == gem_name.downcase
            next if version && version != gem_version
            show_plugin(name, version)
          }
        }
      end

      stdout.puts
    end

    def all?
      config[:all]
    end

    def show_plugin(name, version)
      name = "bones-#{name}"
      name << "-#{version}" if version

      stdout.puts("  [%s]  %s" % [installed?(name) ? colorize('installed', :green) : colorize('available', :cyan), name])
    end

  private

    def find_gemspecs
      if Gem::Specification.respond_to? :map
        specs = Gem::Specification.map { |spec| spec }
      else
        specs = Gem.source_index.map { |_, spec| spec }
      end

      specs.map! { |s| [s.name, s.version.segments.first] }
      specs.sort! { |a, b|
        names = a.first <=> b.first
        next names if names.nonzero?
        b.last <=> a.last
      }

      specs.uniq!
      return specs
    end

    def find_bones_plugins
      fetcher = Gem::SpecFetcher.fetcher
      specs = fetcher.detect(:latest) do |name_tuple|
        %r/\Abones/.match?(name_tuple.name)
      end

      specs.map! do |tuple, _|
        next unless tuple.name =~ %r/\Abones-(.*?)(?:-(\d+))?\Z/i
        $2 ? [$1, $2.to_i] : $1
      end

      specs.compact!
      specs.uniq!
      return specs
    end

    def installed?(name, version = Gem::Requirement.default)
      # FIXME: check for rubygems version 1.8.X
      if Gem::Specification.respond_to? :find_by_name
        begin
          Gem::Specification.find_by_name(name, version)
          true
        rescue Gem::LoadError
          false
        end
      else
        dep = Gem::Dependency.new name, version
        !Gem.source_index.search(dep).empty?
      end
    end
  end
end

