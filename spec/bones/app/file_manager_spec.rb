
require File.expand_path(
    File.join(File.dirname(__FILE__), %w[.. .. spec_helper]))

# --------------------------------------------------------------------------
describe Bones::App::FileManager do

  before :each do
    @fm = Bones::App::FileManager.new
  end

  after :each do
    FileUtils.rm_rf(@fm.destination) if @fm.destination
    FileUtils.rm_rf(@fm.archive) if @fm.archive
  end

  it "should have a configurable source" do
    @fm.source.should be_nil

    @fm.source = '/home/user/.mrbones/data'
    @fm.source.should == '/home/user/.mrbones/data'
  end

  it "should have a configurable destination" do
    @fm.destination.should be_nil

    @fm.destination = 'my_new_app'
    @fm.destination.should == 'my_new_app'
  end

  it "should set the archive directory when the destination is set" do
    @fm.archive.should be_nil

    @fm.destination = 'my_new_app'
    @fm.archive.should == 'my_new_app.archive'
  end

  it "should return a list of files to copy" do
    @fm.source = Bones.path %w[spec data data]

    ary = @fm._files_to_copy
    ary.length.should == 6

    ary.should == %w[
      .bnsignore
      History
      NAME/NAME.rb.bns
      README.txt.bns
      Rakefile.bns
      lib/NAME.rb.bns
    ]
  end

  it "should archive the destination directory if it exists" do
    @fm.destination = Bones.path(%w[spec data bar])
    test(?e, @fm.destination).should == false
    test(?e, @fm.archive).should == false

    FileUtils.mkdir @fm.destination
    @fm.archive_destination
    test(?e, @fm.destination).should == false
    test(?e, @fm.archive).should == true
  end

  it "should rename files and folders containing 'NAME'" do
    @fm.source = Bones.path(%w[spec data data])
    @fm.destination = Bones.path(%w[spec data bar])
    @fm.copy

    @fm._rename(File.join(@fm.destination, 'NAME'), 'tirion')

    dir = File.join(@fm.destination, 'tirion')
    test(?d, dir).should == true
    test(?f, File.join(dir, 'tirion.rb.bns')).should == true
  end

  it "should raise an error when renaming an existing file or folder" do
    @fm.source = Bones.path(%w[spec data data])
    @fm.destination = Bones.path(%w[spec data bar])
    @fm.copy

    lambda {@fm._rename(File.join(@fm.destination, 'NAME'), 'lib')}.
      should raise_error(RuntimeError)
  end

  it "should perform ERb templating on '.bns' files" do
    @fm.source = Bones.path(%w[spec data data])
    @fm.destination = Bones.path(%w[spec data bar])
    @fm.copy
    @fm.finalize('foo_bar')

    dir = @fm.destination
    test(?e, File.join(dir, 'Rakefile.bns')).should == false
    test(?e, File.join(dir, 'README.txt.bns')).should == false
    test(?e, File.join(dir, %w[foo_bar foo_bar.rb.bns])).should == false

    test(?e, File.join(dir, 'Rakefile')).should == true
    test(?e, File.join(dir, 'README.txt')).should == true
    test(?e, File.join(dir, %w[foo_bar foo_bar.rb])).should == true

    txt = File.read(File.join(@fm.destination, %w[foo_bar foo_bar.rb]))
    txt.should == <<-TXT
module FooBar
  def self.foo_bar
    p 'just a test'
  end
end
    TXT
  end

  # ------------------------------------------------------------------------
  describe 'when configured with a repository as a source' do

    it "should recognize a git repository" do
      @fm.source = 'git://github.com/TwP/bones.git'
      @fm.repository.should == :git

      @fm.source = 'git://github.com/TwP/bones.git/'
      @fm.repository.should == :git
    end

    it "should recognize an svn repository" do
      @fm.source = 'file:///home/user/svn/ruby/trunk/apc'
      @fm.repository.should == :svn

      @fm.source = 'http://svn.ruby-lang.org/repos/ruby/branches/ruby_1_8'
      @fm.repository.should == :svn

      @fm.source = 'https://svn.ruby-lang.org/repos/ruby/branches/ruby_1_8'
      @fm.repository.should == :svn

      @fm.source = 'svn://10.10.10.10/project/trunk'
      @fm.repository.should == :svn

      @fm.source = 'svn+ssh://10.10.10.10/project/trunk'
      @fm.repository.should == :svn
    end

    it "should return nil if the source is not a repository" do
      @fm.source = '/some/directory/on/your/hard/drive'
      @fm.repository.should == nil
    end
  end

end

# EOF
