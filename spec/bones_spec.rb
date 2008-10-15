
require File.expand_path(
    File.join(File.dirname(__FILE__), 'spec_helper'))

describe Bones do

  before :all do
    @root_dir = File.expand_path(File.join(File.dirname(__FILE__), '..'))
  end

  it "finds things releative to 'root'" do
    Bones.path(%w[lib bones debug]).
        should == File.join(@root_dir, %w[lib bones debug])
  end 
    
end  # describe Bones

# EOF
