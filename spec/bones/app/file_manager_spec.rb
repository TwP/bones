
require File.expand_path('../../../spec_helper', __FILE__)

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
    expect(@fm.source).to be_nil

    @fm.source = '/home/user/.mrbones/default'
    expect(@fm.source).to eq('/home/user/.mrbones/default')
  end

  it "should have a configurable destination" do
    expect(@fm.destination).to be_nil

    @fm.destination = 'my_new_app'
    expect(@fm.destination).to eq('my_new_app')
  end

  it "should set the archive directory when the destination is set" do
    expect(@fm.archive).to be_nil

    @fm.destination = 'my_new_app'
    expect(@fm.archive).to eq('my_new_app.archive')
  end

  it "should return a list of files to copy" do
    @fm.source = Bones.path %w[spec data default]

    ary = @fm._files_to_copy
    expect(ary.length).to eq(8)

    expect(ary).to eq(%w[
      .bnsignore
      .rvmrc.bns
      History
      NAME/NAME.rb.bns
      README.md.bns
      Rakefile.bns
      bin/NAME.bns
      lib/NAME.rb.bns
    ])
  end

  it "should archive the destination directory if it exists" do
    @fm.destination = Bones.path(%w[spec data bar])
    expect(test(?e, @fm.destination)).to be false
    expect(test(?e, @fm.archive)).to     be false

    FileUtils.mkdir @fm.destination
    @fm.archive_destination
    expect(test(?e, @fm.destination)).to be false
    expect(test(?e, @fm.archive)).to     be true
  end

  it "should rename files and folders containing 'NAME'" do
    @fm.source = Bones.path(%w[spec data default])
    @fm.destination = Bones.path(%w[spec data bar])
    @fm.copy

    @fm._rename(File.join(@fm.destination, 'NAME'), 'tirion')

    dir = File.join(@fm.destination, 'tirion')
    expect(test(?d, dir)).to be true
    expect(test(?f, File.join(dir, 'tirion.rb.bns'))).to be true
  end

  it "should raise an error when renaming an existing file or folder" do
    @fm.source = Bones.path(%w[spec data default])
    @fm.destination = Bones.path(%w[spec data bar])
    @fm.copy

    expect {@fm._rename(File.join(@fm.destination, 'NAME'), 'lib')}.to raise_error(RuntimeError)
  end

  it "should perform ERb templating on '.bns' files" do
    @fm.source = Bones.path(%w[spec data default])
    @fm.destination = Bones.path(%w[spec data bar])
    @fm.template('foo_bar')

    dir = @fm.destination
    expect(test(?e, File.join(dir, 'Rakefile.bns'))).to be false
    expect(test(?e, File.join(dir, 'README.md.bns'))).to be false
    expect(test(?e, File.join(dir, %w[foo_bar foo_bar.rb.bns]))).to be false
    expect(test(?e, File.join(dir, '.rvmrc.bns'))).to be false

    expect(test(?e, File.join(dir, 'Rakefile'))).to be true
    expect(test(?e, File.join(dir, 'README.md'))).to be true
    expect(test(?e, File.join(dir, %w[foo_bar foo_bar.rb]))).to be true
    expect(test(?e, File.join(dir, '.rvmrc'))).to be true

    txt = File.read(File.join(@fm.destination, %w[foo_bar foo_bar.rb]))
    expect(txt).to eq <<-TXT
module FooBar
  def self.foo_bar
    p 'just a test'
  end
end
    TXT
  end

  it "preserves the executable status of .bns files" do
    @fm.source = Bones.path(%w[spec data default])
    @fm.destination = Bones.path(%w[spec data bar])
    @fm.template('foo_bar')

    dir = @fm.destination
    expect(test(?e, File.join(dir, 'bin/foo_bar'))).to be true
    expect(test(?x, File.join(dir, 'bin/foo_bar'))).to be true
  end

  # ------------------------------------------------------------------------
  describe 'when configured with a repository as a source' do

    it "should recognize a git repository" do
      @fm.source = 'git://github.com/TwP/bones.git'
      expect(@fm.repository).to eq(:git)

      @fm.source = 'git://github.com/TwP/bones.git/'
      expect(@fm.repository).to eq(:git)
    end

    it "should recognize an svn repository" do
      @fm.source = 'file:///home/user/svn/ruby/trunk/apc'
      expect(@fm.repository).to eq(:svn)

      @fm.source = 'http://svn.ruby-lang.org/repos/ruby/branches/ruby_1_8'
      expect(@fm.repository).to eq(:svn)

      @fm.source = 'https://svn.ruby-lang.org/repos/ruby/branches/ruby_1_8'
      expect(@fm.repository).to eq(:svn)

      @fm.source = 'svn://10.10.10.10/project/trunk'
      expect(@fm.repository).to eq(:svn)

      @fm.source = 'svn+ssh://10.10.10.10/project/trunk'
      expect(@fm.repository).to eq(:svn)
    end

    it "should return nil if the source is not a repository" do
      @fm.source = '/some/directory/on/your/hard/drive'
      expect(@fm.repository).to be_nil
    end
  end
end

