# frozen_string_literal: true

require "google/apis/gmail_v1"
require "googleauth"
require "googleauth/stores/file_token_store"
require "fileutils"

module CTD
  class GmailScanner
    EMAIL_REGEX = "^(?=[A-Z0-9][A-Z0-9@._%+-]{5,253}+$)[A-Z0-9._%+-]{1,64}+@(?:(?=[A-Z0-9-]{1,63}+\\.)[A-Z0-9]++(?:-[A-Z0-9]++)*+\\.){1,8}+[A-Z]{2,63}+$"

    def self.associate_threads
      MostlyGmail::Message.new_design_requests.each do |message|
        next unless message.streak_box_key
        next if Request.where(thread_gmail_id: message.thread_id).any?
        box = MostlyStreak::Box.find(message.streak_box_key)
        box.add_thread(message.streak_box_key, message.thread_id)
        box.update(notes: message.text_body)
        find_request_for_message(message).update thread_gmail_id: message.thread_id

        MostlyGmail::Thread.modify(
          message.thread_id,
          [Settings.gmail.labels.design_requests],
          [Settings.gmail.labels.new_design_requests]
        )
      end
    end

    def self.find_request_for_message(message)
      request = Request.find_by_streak_box_key(message.streak_box_key)
      return request if request
      email = message.subject.gsub(/^.+ \((.+)\).*$/, "\\1")
      request = Request.joins(:user).where(streak_box_key: nil, users: { email: email.strip.downcase }).last
      request
    end
  end
end
