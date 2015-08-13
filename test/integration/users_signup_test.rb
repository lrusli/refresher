require 'test_helper'

class UsersSignupTest < ActionDispatch::IntegrationTest
  test "invalid signup information" do
    get signup_path
    assert_no_difference 'User.count' do
      post users_path, user: { name: "a",
                               email: "b",
                               password: "c",
                               password_confirmation: "d" } 
    end

    # invalid submissions should return to signup page
    assert_template 'users/new'
    assert_select '.error-explanation'
    assert_select '.field_with_errors'
  end

  test "valid signup information" do
    get signup_path
    assert_difference 'User.count', 1 do
      # follow redirect after posting
      post_via_redirect users_path, user: { name: "Alan",
                                            email: "alan@example.com",
                                            password: "alanexample",
                                            password_confirmation: "alanexample" }
    end

    assert_template 'users/show'
    assert_not flash.empty?
  end
end
