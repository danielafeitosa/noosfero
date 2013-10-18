require File.dirname(__FILE__) + '/../../test_helper'

class TrackCardListBlockTest < ActiveSupport::TestCase

  def setup
    @community = fast_create(Community)
    box = fast_create(Box, :owner_id => @community.id, :owner_type => @community.class.name)
    @block = CommunityTrackPlugin::TrackCardListBlock.create!(:box => box)
  end

  should 'describe yourself' do
    assert CommunityTrackPlugin::TrackCardListBlock.description
  end

  should 'has title' do
    assert @block.default_title
  end

  should 'return track_card as track partial' do
    assert_equal 'track_card', @block.track_partial
  end

end
