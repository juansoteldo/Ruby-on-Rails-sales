require "test_helper"

class SettingTest < ActiveSupport::TestCase
  test "Auto-quoting is boolean" do
    assert_equal "boolean", Setting.auto_quoting.data_type
  end

  test "Boolean is boolean type" do
    Setting.auto_quoting.update! value: false
    assert_equal FalseClass, Setting.auto_quoting.value.class
  end

  test "String is string type" do
    Setting.auto_quoting.update! value: false
    assert_equal FalseClass, Setting.auto_quoting.value.class
  end
end
