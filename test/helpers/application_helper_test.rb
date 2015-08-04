require 'test_helper'

class ApplicationHelperTest < ActionView::TestCase
  test "full title helper" do
    assert_equal full_title,         "Refresher"
    assert_equal full_title("Help"), "Help | Refresher"
  end
end