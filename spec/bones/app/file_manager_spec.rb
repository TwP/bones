
require File.expand_path(
    File.join(File.dirname(__FILE__), %w[.. .. spec_helper]))

# --------------------------------------------------------------------------
describe Bones::App::FileManager do

  before :each do
    @main = Bones::App::FileManager.new
  end

  it "should have a configurable destination"

  it "should set the archive directory when the destination is set"

  # ------------------------------------------------------------------------
  describe 'when configured with a repository as a source' do

    it "should recognize a git repository" do
      @main.source = 'git://github.com/TwP/bones.git'
      @main.repository.should == :git

      @main.source = 'git://github.com/TwP/bones.git/'
      @main.repository.should == :git
    end

    it "should recognize an svn repository" do
      @main.source = 'file:///home/user/svn/ruby/trunk/apc'
      @main.repository.should == :svn

      @main.source = 'http://svn.ruby-lang.org/repos/ruby/branches/ruby_1_8'
      @main.repository.should == :svn

      @main.source = 'https://svn.ruby-lang.org/repos/ruby/branches/ruby_1_8'
      @main.repository.should == :svn

      @main.source = 'svn://10.10.10.10/project/trunk'
      @main.repository.should == :svn

      @main.source = 'svn+ssh://10.10.10.10/project/trunk'
      @main.repository.should == :svn
    end

    it "should return nil if the source is not a repository" do
      @main.source = '/some/directory/on/your/hard/drive'
      @main.repository.should == nil
    end
  end

end

# EOF
