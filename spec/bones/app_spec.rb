
require File.expand_path('../../spec_helper', __FILE__)

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
    allow(@runner).to receive(:parse).and_return(Hash.new)

    @app = Bones::App::Main.new(:stdout => @out, :stderr => @err)

    allow(Bones::App::Create).to   receive(:new) {@runner.name = :create; @runner}
    allow(Bones::App::Freeze).to   receive(:new) {@runner.name = :freeze; @runner}
    allow(Bones::App::Unfreeze).to receive(:new) {@runner.name = :unfreeze; @runner}
    allow(Bones::App::Info).to     receive(:new) {@runner.name = :info; @runner}
  end

  after :each do
    @out.clear
    @err.clear
  end

  it 'should provide a create command' do
    @app.run %w[create]
    expect(@runner.name).to eq(:create)
  end

  it 'should provide a freeze command' do
    @app.run %w[freeze]
    expect(@runner.name).to eq(:freeze)
  end

  it 'should provide an unfreeze command' do
    @app.run %w[unfreeze]
    expect(@runner.name).to eq(:unfreeze)
  end

  it 'should provide an info command' do
    @app.run %w[info]
    expect(@runner.name).to eq(:info)
  end

  it 'should provide a help command' do
    @app.run %w[--help]
    4.times { @out.readline }
    expect(@out.readline).to match(%r/^  Mr Bones is a handy tool that builds/)
    @out.clear

    @app.run %w[-h]
    4.times { @out.readline }
    expect(@out.readline).to match(%r/^  Mr Bones is a handy tool that builds/)
  end

  it 'should default to the help message if no command is given' do
    @app.run []
    4.times { @out.readline }
    expect(@out.readline).to match(%r/^  Mr Bones is a handy tool that builds/)
  end

  it 'should report an error for unrecognized commands' do
    expect {@app.run %w[foo]}.to raise_error(SystemExit)
    expect(@err.readline).to eq("\e[37m\e[41mERROR\e[0m:  While executing bones ...")
    expect(@err.readline).to eq('    Unknown command "foo"')
  end

  it 'should report a version number' do
    @app.run %w[--version]
    expect(@out.readline).to eq("Mr Bones v#{Bones.version}")
    @out.clear

    @app.run %w[-v]
    expect(@out.readline).to eq("Mr Bones v#{Bones.version}")
  end
end

