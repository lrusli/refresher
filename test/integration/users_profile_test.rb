require 'test_helper'

class UsersProfileTest < ActionDispatch::IntegrationTest
  # To use full_title helper.
  include ApplicationHelper

  def setup
    @user = users(:kobe)
  end

  test "profile display" do
    get user_path(@user)
    assert_template 'users/show'
    assert_select 'title', full_title(@user.name)
    assert_select 'h1', text: @user.name
    assert_select '.gravatar'
    # Check micropost count.
    assert_match @user.microposts.count.to_s, response.body
    # Check pagination links exist.
    assert_select '.pagination'
    # Check all microposts are present.
    @user.microposts.paginate(page: 1).each do |micropost|
      assert_match micropost.content, response.body
    end  
  end
end
