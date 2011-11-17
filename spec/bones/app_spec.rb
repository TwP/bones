
require 'spec_helper'

class Runner
  attr_accessor :name
  def run(*a, &b) nil; end
end

describe Bones::App do

  before :all do
    @out = StringIO.new
    @err = StringIO.new
    Bones::App.initialize_plugins
  end

  before :each do
    @runner = ::Runner.new
    @runner.stub!(:parse).and_return(Hash.new)

    @app = Bones::App::Main.new(:stdout => @out, :stderr => @err)

    Bones::App::Create.stub!(:new).
        and_return {@runner.name = :create; @runner}
    Bones::App::Freeze.stub!(:new).
        and_return {@runner.name = :freeze; @runner}
    Bones::App::Unfreeze.stub!(:new).
        and_return {@runner.name = :unfreeze; @runner}
    Bones::App::Info.stub!(:new).
        and_return {@runner.name = :info; @runner}
  end

  after :each do
    @out.clear
    @err.clear
  end

  it 'should provide a create command' do
    @app.run %w[create]
    @runner.name.should be == :create
  end

  it 'should provide a freeze command' do
    @app.run %w[freeze]
    @runner.name.should be == :freeze
  end

  it 'should provide an unfreeze command' do
    @app.run %w[unfreeze]
    @runner.name.should be == :unfreeze
  end

  it 'should provide an info command' do
    @app.run %w[info]
    @runner.name.should be == :info
  end

  it 'should provide a help command' do
    @app.run %w[--help]
    4.times { @out.readline }
    @out.readline.should match(%r/^  Mr Bones is a handy tool that builds/)
    @out.clear

    @app.run %w[-h]
    4.times { @out.readline }
    @out.readline.should match(%r/^  Mr Bones is a handy tool that builds/)
  end

  it 'should default to the help message if no command is given' do
    @app.run []
    4.times { @out.readline }
    @out.readline.should match(%r/^  Mr Bones is a handy tool that builds/)
  end

  it 'should report an error for unrecognized commands' do
    lambda {@app.run %w[foo]}.should raise_error(SystemExit)
    @err.readline.should be == "\e[37m\e[41mERROR\e[0m:  While executing bones ..."
    @err.readline.should be == '    Unknown command "foo"'
  end

  it 'should report a version number' do
    @app.run %w[--version]
    @out.readline.should be == "Mr Bones v#{Bones.version}"
    @out.clear

    @app.run %w[-v]
    @out.readline.should be == "Mr Bones v#{Bones.version}"
  end

end  # describe Bones::App

# EOF
