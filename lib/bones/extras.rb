

PROJ = OpenStruct.new(

  # Announce
  :ann => OpenStruct.new(
    :file => 'announcement.txt',
    :text => nil,
    :paragraphs => [],
    :email => {
      :from     => nil,
      :to       => %w(ruby-talk@ruby-lang.org),
      :server   => 'localhost',
      :port     => 25,
      :domain   => ENV['HOSTNAME'],
      :acct     => nil,
      :passwd   => nil,
      :authtype => :plain
    }
  ),

  # Rcov
  :rcov => OpenStruct.new(
    :dir => 'coverage',
    :opts => %w[--sort coverage -T],
    :threshold => 90.0,
    :threshold_exact => false
  ),

  # Rubyforge
  :rubyforge => OpenStruct.new(
    :name => "\000"
  ),

  # Rspec
  :spec => OpenStruct.new(
    :files => FileList['spec/**/*_spec.rb'],
    :opts => []
  ),

  # Subversion Repository
  :svn => OpenStruct.new(
    :root => nil,
    :path => '',
    :trunk => 'trunk',
    :tags => 'tags',
    :branches => 'branches'
  ),

  # Test::Unit
  :test => OpenStruct.new(
    :files => FileList['test/**/test_*.rb'],
    :file  => 'test/all.rb',
    :opts  => []
  )
)

# Load the other rake files in the tasks folder
tasks_dir = File.expand_path(File.dirname(__FILE__))
post_load_fn = File.join(tasks_dir, 'post_load.rake')
rakefiles = Dir.glob(File.join(tasks_dir, '*.rake')).sort
rakefiles.unshift(rakefiles.delete(post_load_fn)).compact!
import(*rakefiles)

# Setup the project libraries
%w(lib ext).each {|dir| PROJ.libs << dir if test ?d, dir}

# Add bones as a development dependency
#
#PROJ.gem.development_dependencies << ['bones', ">= #{Bones::VERSION}"]

%w(rcov spec/rake/spectask rubyforge bones facets/ansicode zentest).each do |lib|
  begin
    require lib
    Object.instance_eval {const_set "HAVE_#{lib.tr('/','_').upcase}", true}
  rescue LoadError
    Object.instance_eval {const_set "HAVE_#{lib.tr('/','_').upcase}", false}
  end
end

# EOF
