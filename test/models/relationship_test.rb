require 'test_helper'

class RelationshipTest < ActiveSupport::TestCase

  def setup
    @relationship = Relationship.new( following_id: users(:michael).id,
                                      followed_id:  users(:archer).id)
  end

  test "should be valid" do
    assert @relationship.valid?
  end

  test "should require a following_id" do
    @relationship.following_id = nil
    assert_not @relationship.valid?
  end

  test "should require a followed_id" do
    @relationship.followed_id = nil
    assert_not @relationship.valid?
  end
end
