
require File.expand_path('../spec_helper', __FILE__)

describe Bones do

  before :all do
    @root_dir = File.expand_path(File.join(File.dirname(__FILE__), '..'))
  end

  it "finds things releative to 'root'" do
    expect(Bones.path(%w[lib bones helpers])).to eq(File.join(@root_dir, %w[lib bones helpers]))
  end

  it "finds things releative to 'lib'" do
    expect(Bones.libpath(%w[bones helpers])).to eq(File.join(@root_dir, %w[lib bones helpers]))
  end
end

