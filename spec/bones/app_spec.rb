
require File.expand_path(
    File.join(File.dirname(__FILE__), %w[.. spec_helper]))

describe Bones::App do

  before :each do
    @main = Bones::App.new
    @skeleton_dir = File.join(@main.mrbones_dir, 'data')
    @skeleton_dir = Bones.path('data') unless test(?e, @skeleton_dir)
  end

  it 'has some defaults when initialized' do
    @main.options.should == {
      :skeleton_dir => @skeleton_dir,
      :with_tasks => false,
      :verbose => false,
      :name => nil,
      :output_dir => nil,
      :action => nil
    }
  end

  it 'provides access to the output_dir' do
    @main.output_dir.should be_nil
    @main.options[:output_dir] = 'foo'
    @main.output_dir.should == 'foo'
  end

  it 'provides access to the skeleton_dir' do
    @main.skeleton_dir.should == @skeleton_dir
    @main.options[:skeleton_dir] = 'bar'
    @main.skeleton_dir.should == 'bar'
  end

  it 'provides access to the project name' do
    @main.name.should be_nil
    @main.options[:name] = 'baz'
    @main.name.should == 'baz'
  end

  it 'provides access to the project classname' do
    @main.options[:name] = 'foo-bar'
    @main.classname.should == 'FooBar'
  end

  it 'determines if a project should be updated' do
    @main.options[:output_dir] = Bones.path
    @main.update?.should == false

    @main.options[:with_tasks] = true
    @main.update?.should == true

    @main.options[:output_dir] = Bones.path(%w[foo bar baz buz tmp])
    @main.update?.should == false
  end

  # ------------------------------------------------------------------------
  describe 'when parsing command line options' do

    before :each do
      @main.stub!(:mrbones_dir).and_return(Bones.path(%w[spec data]))
    end

    it 'parses the project name' do
      @main.parse %w[foo-bar]
      @main.name.should == 'foo-bar'
      @main.output_dir.should == 'foo-bar'
    end

    it 'parses the verbose flag' do
      @main.parse %w[-v foo-bar]
      @main.name.should == 'foo-bar'
      @main.verbose?.should == true

      @main = Bones::App.new
      @main.parse %w[--verbose foo-bar]
      @main.name.should == 'foo-bar'
      @main.verbose?.should == true
    end

    it 'parses the directory flag' do
      @main.parse %w[-d blah foo-bar]
      @main.name.should == 'foo-bar'
      @main.output_dir.should == 'blah'

      @main = Bones::App.new
      @main.parse %w[--directory blah foo-bar]
      @main.name.should == 'foo-bar'
      @main.output_dir.should == 'blah'
    end

    it 'parses the directory flag' do
      @main.parse %w[-d blah foo-bar]
      @main.name.should == 'foo-bar'
      @main.output_dir.should == 'blah'

      @main = Bones::App.new
      @main.parse %w[--directory blah foo-bar]
      @main.name.should == 'foo-bar'
      @main.output_dir.should == 'blah'
    end

    it 'parses the skeleton to use flag' do
      @main.stub!(:mrbones_dir).and_return(Bones.path(%w[spec data]))
      @main.parse %w[-s data foo-bar]
      @main.name.should == 'foo-bar'
      @main.skeleton_dir.should == Bones.path(%w[spec data data])

      @main = Bones::App.new
      @main.stub!(:mrbones_dir).and_return(Bones.path(%w[spec data]))
      @main.parse %w[--skeleton foo foo-bar]
      @main.name.should == 'foo-bar'
      @main.skeleton_dir.should == Bones.path(%w[spec data foo])
    end

    it 'parses the with-tasks flag' do
      @main.parse %w[--with-tasks foo-bar]
      @main.name.should == 'foo-bar'
      @main.with_tasks?.should == true
    end

    it 'parses the freeze flag' do
      @main.parse %w[--freeze]
      @main.name.should be_nil
      @main.options[:action].should == :freeze

      @main = Bones::App.new
      @main.parse %w[--freeze foo-bar]
      @main.name.should == 'foo-bar'
      @main.options[:action].should == :freeze
    end

    it 'parses the unfreeze flag' do
      @main.parse %w[--unfreeze]
      @main.name.should be_nil
      @main.options[:action].should == :unfreeze
    end

    it 'parses the info flag' do
      @main.parse %w[--info]
      @main.name.should be_nil
      @main.options[:action].should == :info

      @main = Bones::App.new
      @main.parse %w[-i]
      @main.name.should be_nil
      @main.options[:action].should == :info
    end

    it 'parses the repository flag' do
      @main.parse %w[--freeze --repository git://github.com/TwP/bones.git]
      @main.repository.should == 'git://github.com/TwP/bones.git'
      @main.options[:action].should == :freeze

      @main = Bones::App.new
      @main.parse %w[--freeze -r http://example.com/projects/sts/svn/trunk]
      @main.repository.should == 'http://example.com/projects/sts/svn/trunk'
      @main.options[:action].should == :freeze
    end
  end

  # ------------------------------------------------------------------------
  #describe 'when archiving tasks'

end  # describe Bones::App

# EOF
