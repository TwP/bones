# Equivalent to a header guard in C/C++
# Used to prevent the spec helper from being loaded more than once
unless defined? BONES_SPEC_HELPER
BONES_SPEC_HELPER = true

require File.expand_path(
    File.join(File.dirname(__FILE__), %w[.. lib bones]))

Spec::Runner.configure do |config|
  # == Mock Framework
  #
  # RSpec uses it's own mocking framework by default. If you prefer to
  # use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr
end

end  # unless defined?

# EOF
