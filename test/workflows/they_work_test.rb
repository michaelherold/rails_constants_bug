require 'test_helper'

class TheyWorkTest < ActiveSupport::TestCase
  test 'the constants resolution can find them' do
    Workflows::Null.new
  end
end
