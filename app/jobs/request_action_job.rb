# frozen_string_literal: true

# Executes a Request action (method) asynchronously
class RequestActionJob < ApplicationJob
  retry_on Streak::APIError, wait: 15.seconds, attempts: 6

  def perform(args)
    request = args[:request]
    if args[:args].nil?
      request.send(args[:method].to_sym)
    else
      request.send(args[:method].to_sym, args[:args])
    end
  end
end
