require 'test_helper'

class MicropostTest < ActiveSupport::TestCase
  def setup
    @user = users(:kobe)
    # Not idiomatically correct. Doesn't associate micropost with user.
    #@micropost = Micropost.new(content: "Hey hey!", user_id: @user.id)
    @micropost = @user.microposts.build(content: "Hey hey!")
  end

  test "should be valid" do
    assert @micropost.valid? 
  end

  test "user id should be present" do
    @micropost.user_id = nil
    assert_not @micropost.valid?
  end

  test "content should be present" do
    @micropost.content = "    "
    assert_not @micropost.valid?
  end

  test "content should be at most 140 characters" do
    @micropost.content = "z" * 141
    assert_not @micropost.valid?
  end

  test "order should be most recent first" do
    assert_equal microposts(:most_recent), Micropost.first
  end
end
