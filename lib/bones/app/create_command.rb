
module Bones::App

class CreateCommand < Command

  Error = Class.new(StandardError)

  def run
    raise Error, "Output directory #{output_dir.inspect} already exists." if test ?e, output_dir

    copy_files

    pwd = File.expand_path(FileUtils.pwd)
    msg = "Created '#{name}'"
    msg << " in directory '#{output_dir}'" if name != output_dir
    @out.puts msg

    in_directory(output_dir) {
      initialize_git if git?
      initialize_github if github?

      break unless test ?f, 'Rakefile'
      @out.puts 'Now you need to fix these files'
      system "#{::Bones::RUBY} -S rake notes"
    }
  end

  def copy_files
    fm = FileManager.new(
      :source => repository || skeleton_dir,
      :destination => output_dir,
      :stdout => @out,
      :stderr => @err,
      :verbose => verbose?
    )

    fm.copy
    fm.finalize name
  rescue Bones::App::FileManager::Error => err
    FileUtils.rm_rf output_dir
    msg = "Could not create '#{name}'"
    msg << " in directory '#{output_dir}'" if name != output_dir
    msg << "\n\t#{err.message}"
    raise Error, msg
  rescue Exception => err
    FileUtils.rm_rf output_dir
    msg = "Could not create '#{name}'"
    msg << " in directory '#{output_dir}'" if name != output_dir
    msg << "\n\t#{err.inspect}"
    raise Error, msg
  end

  def git?
    @params['git'] or @params['github']
  end

  def initialize_git
    File.rename('.bnsignore', '.gitignore') if test ?f, '.bnsignore'

    author = Git.global_config['user.name']
    email  = Git.global_config['user.email']

    if test ?f, 'Rakefile'
      lines = File.readlines 'Rakefile'

      lines.each do |line|
        case line
        when %r/^\s*authors\s+/
          line.replace "  authors  '#{author}'" unless author.nil? or line !~ %r/FIXME/
        when %r/^\s*email\s+/
          line.replace "  email  '#{email}'" unless email.nil? or line !~ %r/FIXME/
        when %r/^\s*url\s+/
          next unless github?
          url = github_url
          line.replace "  url  '#{url}'" unless url.nil? or line !~ %r/FIXME/
        when %r/^\s*\}\s*$/
          line.insert 0, "  ignore_file  '.gitignore'\n" if test ?f, '.gitignore'
        end
      end

      File.open('Rakefile', 'w') {|fd| fd.puts lines}
    end

    @git = Git.init
    @git.add
    @git.commit "Initial commit to #{name}."
  end

  def github?
    @params['github']
  end

  def initialize_github
    user = Git.global_config['github.user']
    token = Git.global_config['github.token']

    raise Error, 'A GitHub username was not found in the global configuration.' unless user
    raise Error, 'A GitHub token was not found in the global configuration.' unless token

    Net::HTTP.post_form(
        URI.parse('http://github.com/api/v2/yaml/repos/create'),
        'login' => user,
        'token' => token,
        'name' => name,
        'description' => description
    )

    @git.add_remote 'origin', "git@github.com:#{user}/#{name}.git"
    @git.config 'branch.master.remote', 'origin'
    @git.config 'branch.master.merge', 'refs/heads/master'
    @git.push 'origin'
  end

  def github_url
    user = Git.global_config['github.user']
    return unless user
    "http://github.com/#{user}/#{name}"
  end

  def description
    String === @params['github'] ? @params['github'] : nil
  end

end  # class CreateCommand
end  # module Bones::App

# EOF
