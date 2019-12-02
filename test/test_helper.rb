ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require "rails/test_help"
require "minitest/rails/capybara"

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  def clear_requests_for(email)
    RequestImage.joins(:user).where(email: email).each &:destroy!
    Request.joins(:user).where(email: email).each &:destroy!
    User.where(email: email).each &:destroy!
  end

  def wpcf7_params
    {
      first_name: "John",
      last_name: "Smith",
      email: "johnsmith@example.com",
      position: "Sleeve",
      has_color: "0",
      is_first_time: "0",
      gender: "Male",
      description: "Test test",
      art_sample_1: "",
      art_sample_2: "",
      art_sample_3: "",
      linker_param: "",
      _ga: "",
      client_id: "",
      user_attributes: { marketing_opt_in: "1" },
    }.with_indifferent_access
  end

  def shopify_params
    payload = File.open(File.join(__dir__, "fixtures/files/shopify_payload.json")).read
    JSON.parse(payload).with_indifferent_access
  end

  def shopify_unassociated_params
    payload = File.open(File.join(__dir__, "fixtures/files/shopify_unassociated_payload.json")).read
    JSON.parse(payload).with_indifferent_access
  end

  def file_fixture_copy(name)
    src_file = file_fixture(name)
    extname = File.extname(name).to_s
    FileUtils.mkdir_p(Rails.root.join("tmp", "storage"))
    path = Rails.root.join("tmp", "storage", "#{Time.now.to_i}#{extname}")
    FileUtils.cp src_file, path
    Pathname.new(path)
  end

  def new_streak_box_for_email(email)
    box = MostlyStreak::Box.find_by_email email
    box ||= MostlyStreak::Box.create(email)
    box_key = box.key
    MostlyStreak::Box.set_stage(box_key, "Leads")
    box = MostlyStreak::Box.find(box_key)
    box
  end

  def request_with_image(path)
    request = requests(:deposited)
    request.add_image_from_param(path)
    request
  end

  def content_type(path)
    `file -Ib #{path}`.gsub(/\n/, "").split(";")[0]
  end
end
