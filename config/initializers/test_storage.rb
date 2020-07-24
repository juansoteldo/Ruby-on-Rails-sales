module RemoveUploadedFiles
  def before_setup
    initialize_storage
    super
  end

  def after_teardown
    super
    remove_uploaded_files
  end

  private

  def initialize_storage
    FileUtils.mkdir_p(tmp_storage)
  end

  def remove_uploaded_files
    FileUtils.rm_rf(tmp_storage)
  end

  def tmp_storage
    Rails.root.join("tmp", "storage")
  end
end

module ActionDispatch
  class IntegrationTest
    prepend RemoveUploadedFiles
  end
end
