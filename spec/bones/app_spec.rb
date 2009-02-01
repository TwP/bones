
require File.expand_path(
    File.join(File.dirname(__FILE__), %w[.. spec_helper]))

class Runner
  attr_accessor :name
  def run(*a, &b) nil; end
end

describe Bones::App do

  before :all do
    @out = StringIO.new
    @err = StringIO.new
  end

  before :each do
    @runner = ::Runner.new
    @app = Bones::App.new(@out, @err)

    Bones::App::CreateCommand.stub!(:new).
        and_return {@runner.name = :create; @runner}
    Bones::App::UpdateCommand.stub!(:new).
        and_return {@runner.name = :update; @runner}
    Bones::App::FreezeCommand.stub!(:new).
        and_return {@runner.name = :freeze; @runner}
    Bones::App::UnfreezeCommand.stub!(:new).
        and_return {@runner.name = :unfreeze; @runner}
    Bones::App::InfoCommand.stub!(:new).
        and_return {@runner.name = :info; @runner}
  end

  after :each do
    @out.clear
    @err.clear
  end

  it 'should provide a create command' do
    @app.run %w[create]
    @runner.name.should == :create
  end

  it 'should provide an update command' do
    @app.run %w[update]
    @runner.name.should == :update
  end

  it 'should provide a freeze command' do
    @app.run %w[freeze]
    @runner.name.should == :freeze
  end

  it 'should provide an unfreeze command' do
    @app.run %w[unfreeze]
    @runner.name.should == :unfreeze
  end

  it 'should provide an info command' do
    @app.run %w[info]
    @runner.name.should == :info
  end

  it 'should provide a help command' do
    @app.run %w[--help]
    @out.readline
    @out.readline.should match(%r/^  Mr Bones is a handy tool that builds/)
    @out.clear

    @app.run %w[-h]
    @out.readline
    @out.readline.should match(%r/^  Mr Bones is a handy tool that builds/)
  end

  it 'should default to the help message if no command is given' do
    @app.run []
    @out.readline
    @out.readline.should match(%r/^  Mr Bones is a handy tool that builds/)
  end

  it 'should report an error for unrecognized commands' do
    lambda {@app.run %w[foo]}.should raise_error(SystemExit)
    @err.readline.should == 'ERROR:  While executing bones ... (RuntimeError)'
    @err.readline.should == '    Unknown command "foo"'
  end

  it 'should report a version number' do
    @app.run %w[--version]
    @out.readline.should == "Mr Bones #{Bones::VERSION}"
    @out.clear

    @app.run %w[-v]
    @out.readline.should == "Mr Bones #{Bones::VERSION}"
  end

end  # describe Bones::App

# EOF
