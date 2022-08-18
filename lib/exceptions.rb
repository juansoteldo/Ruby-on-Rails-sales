module Exceptions
  class NotFoundError < StandardError; end
  class InvalidResponseError < StandardError; end
  # TODO: make more specific errors i.e., "class HTTPResponseError < CampaignMonitorError; end"
  # TODO: create individual log files for Sidekiq based on the type of job
  # TODO: With Rails 6.0.2+, ActiveJobs can now use sidekiq_options directly to configure Sidekiq features/internals like the retry subsystem.
end
