require "test_helper"

class TattooSizeTest < ActiveSupport::TestCase

  test "default has size 0" do
    assert_equal TattooSize.default, tattoo_sizes(:default)
    assert_equal TattooSize.default.size, 0
  end

  test "default has null variant" do
    assert_nil TattooSize.default.variant
  end

  test "non-default have non-null variants" do
    TattooSize.where.not(size: 0).each do |size|
      assert_not_nil size.variant
    end
  end

  test "#for_request blank size returns default" do
    assert_not_nil TattooSize.default
    request = requests(:fresh)
    request.size = ""
    size = TattooSize.for_request(request)
    assert_equal size, tattoo_sizes(:default)
  end

  test "#for_request returns stipulated value" do
    request = requests(:fresh)
    request.deposit_variant = tattoo_sizes(:large).deposit_variant_id
    size = TattooSize.for_request(request)
    assert_equal size, tattoo_sizes(:large)
  end

  test "#for_request half sleeve returns itself" do
    request = requests(:fresh)
    request.size = tattoo_sizes(:half_sleeve).name
    request.style = "Realistic"
    size = TattooSize.for_request(request)
    assert_equal size, tattoo_sizes(:half_sleeve)
  end

  test "#for_request full sleeve returns itself" do
    request = requests(:fresh)
    request.size = tattoo_sizes(:full_sleeve).name
    request.style = "Realistic"
    size = TattooSize.for_request(request)
    assert_equal size, tattoo_sizes(:full_sleeve)
  end

  test "#for_request specific size returns match" do
    request = requests(:fresh)
    request.size = tattoo_sizes(:large).name
    size = TattooSize.for_request(request)
    assert_equal size, tattoo_sizes(:large)
  end

  test "realistic medium returns large" do
    request = requests(:fresh)
    request.size = tattoo_sizes(:medium).name
    request.style = "Realistic"
    size = TattooSize.for_request(request)
    assert_equal size, tattoo_sizes(:large)
  end
end
