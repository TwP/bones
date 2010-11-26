
require 'spec_helper'

describe Bones::Helpers do

  before :each do
    Bones::Helpers::HAVE.clear
  end

  describe 'when given a list of files' do
    it 'finds the one that exists on the filesystem' do
      filename = Bones::Helpers.find_file(*%w[foo.txt bar.txt README History.txt baz buz])
      filename.should == 'History.txt'
    end

    it 'returns the first file if none exist' do
      filename = Bones::Helpers.find_file(*%w[foo.txt bar.txt README History baz buz])
      filename.should == 'foo.txt'
    end
  end

  describe 'when extracting paragraphs' do
    it 'recognizes RDoc headers by title' do
      filename = Bones.path %w[spec data rdoc.txt]

      ary = Bones::Helpers.paragraphs_of(filename, 'install')
      ary.length.should == 6
      ary.first.should == '* gem install bones'
      ary.last.should == %Q{The 'bones-git' gem provides command line options for generating a git\nrepository and pushing to github upon creation. Rake tasks for working with\nthe git repository are also provided.}

      ary = Bones::Helpers.paragraphs_of(filename, 'description')
      ary.length.should == 1

      ary = Bones::Helpers.paragraphs_of(filename, 'license')
      ary.length.should == 4
    end

    it 'recognizes Markdown headers by title' do
      filename = Bones.path %w[spec data markdown.txt]

      ary = Bones::Helpers.paragraphs_of(filename, 'install')
      ary.length.should == 5
      ary.first.should == '* gem install bones'
      ary.last.should == %Q{The 'bones-extras' gem provides rake tasks for running Rspec tests, running\nRcov on your source code, and pushing releases to RubyForge. You will need to\nhave the corresponding gems installed for these tasks to be loaded.}

      ary = Bones::Helpers.paragraphs_of(filename, 'mr bones')
      ary.length.should == 1

      ary = Bones::Helpers.paragraphs_of(filename, 'license')
      ary.length.should == 4
    end

    it 'uses paragraph numbers' do
      filename = Bones.path %w[spec data markdown.txt]

      ary = Bones::Helpers.paragraphs_of(filename, 1, 3..5)
      ary.length.should == 4
      ary.first.should == %Q{Mr Bones is a handy tool that creates new Ruby projects from a code\nskeleton. The skeleton contains some starter code and a collection of rake\ntasks to ease the management and deployment of your source code. Several Mr\nBones plugins are available for creating git repositories, creating GitHub\nprojects, running various test suites and source code analysis tools.}
      ary.last.should == %Q{When working with Rake, Mr Bones provides a set of tasks that help simplify\ncommon development tasks. These tasks include ...}
    end
  end

end

