require 'test_helper'

class StreakBoxCreateJobTest < ActiveJob::TestCase
  setup do
    @previous_create_value = Settings.streak.create_boxes
    Settings.streak.create_boxes = true
    @request = requests(:fresh)
  end

  teardown do
    Settings.streak.create_boxes = @previous_create_value
  end

  test "should create a box with the correct attributes" do
    StreakBoxCreateJob.perform_now(@request)
    assert_not_nil @request.streak_box_key
    box = MostlyStreak::Box.find(@request.streak_box_key)
    assert_equal @request.description, box.notes
  end
end