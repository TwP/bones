
module Bones::Plugins::Git
  include ::Bones::Helpers
  extend self

  def post_load
    have?(:git) {
      Dir.entries(Dir.pwd).include?('.git') and
      system("git --version 2>&1 > #{DEV_NULL}")
    }
  end

  def define_tasks
    return unless have? :git

    config = ::Bones.config
    namespace :git do

      # A prerequisites task that all other tasks depend upon
      task :prereqs

      desc 'Show tags from the git repository'
      task :tags => 'git:prereqs' do |t|
        puts Git.open('.').tags.map {|t| t.name}.reverse
      end

      desc 'Create a new tag in the git repository'
      task :create_tag => 'git:prereqs' do |t|
        v = ENV['VERSION'] or abort 'Must supply VERSION=x.y.z'
        abort "Versions don't match #{v} vs #{config.version}" if v != config.version

        git = Git.open '.'
        tag = "%s-%s" % [config.name, config.version]
        puts "Creating git tag '#{tag}'."

        begin
          git.add_tag tag
        rescue Git::GitExecuteError
          abort "Tag creation failed: tag '#{tag}' already exists."
        end

        if git.remotes.map {|r| r.name}.include? 'origin'
          unless system "git push origin #{tag}"
            abort "Could not push tag to remote git repository."
          end
        end
      end  # task

      desc 'Delete a tag from the git repository'
      task :delete_tag => 'git:prereqs' do |t|
        v = ENV['VERSION'] or abort 'Must supply VERSION=x.y.z'

        git = Git.open '.'
        tag = "%s-%s" % [config.name, v]

        unless git.tags.map {|t| t.name}.include? tag
          puts "Tag '#{tag}' does not exist."
          break
        end

        puts "Deleting git tag '#{tag}'."
        abort 'Tag deletion failed.' unless system "git tag -d '#{tag}'"

        if git.remotes.map {|r| r.name}.include? 'origin'
          unless system "git push origin ':refs/tags/#{tag}'"
            abort "Could not delete tag from remote git repository."
          end
        end
      end  # task

    end  # namespace :git

    task 'gem:release' => 'git:create_tag'
  end

end  # module Bones::Plugins::Git

# EOF
