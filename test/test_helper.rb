ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

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
    }
  end

  def file_fixture_copy(name)
    src_file = file_fixture(name)
    extname = File.extname(name).to_s
    FileUtils.mkdir_p(Rails.root.join("tmp", "storage"))
    path = Rails.root.join("tmp", "storage", "#{Time.now.to_i}#{extname}")
    FileUtils.cp src_file, path
    Pathname.new(path)
  end


  def request_with_image(path)
    request = requests(:deposited)
    request.add_image_from_path(path)
    request
  end

  def content_type(path)
    `file -Ib #{path}`.gsub(/\n/,"").split(";")[0]
  end
end
