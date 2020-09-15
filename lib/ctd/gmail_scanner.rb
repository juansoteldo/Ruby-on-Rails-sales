# frozen_string_literal: true

require "google/apis/gmail_v1"
require "googleauth"
require "googleauth/stores/file_token_store"
require "fileutils"

module CTD
  class GmailScanner
    EMAIL_REGEX = '^(?=[A-Z0-9][A-Z0-9@._%+-]{5,253}+$)[A-Z0-9._%+-]{1,64}+@(?:(?=[A-Z0-9-]{1,63}+\\.)[A-Z0-9]++(?:-[A-Z0-9]++)*+\\.){1,8}+[A-Z]{2,63}+$'

    def self.associate_threads
      MostlyGmail::Message.new_design_requests.each do |message|
        next unless message.streak_box_key
        next if Request.where(thread_gmail_id: message.thread_id).any?

        box = MostlyStreak::Box.find(message.streak_box_key)
        next if box.nil?

        request = find_request_for_message(message)
        add_thread_to_box(message, box, request)
        box.update(notes: message.shortened_utf_8_text_body)
        box.set_stage_by_name("Leads") if box.current_stage.name == "Fresh"
        remove_thread_new_label message

        next unless Setting.auto_quoting.value && request.auto_quotable?

        request.quote_from_attributes!
      end
    end

    def self.remove_thread_new_label(message)
      MostlyGmail::Thread.modify(
        message.thread_id,
        [Settings.gmail.labels.design_requests],
        [Settings.gmail.labels.new_design_requests]
      )
    end

    def self.add_thread_to_box(message, box, request)
      return if request.thread_gmail_id == message.thread_id
      return if MostlyStreak::Thread.all(box.key).map(&:thread_gmail_id).include?(message.thread_id)

      box.add_thread(message.streak_box_key, message.thread_id)
      request.update thread_gmail_id: message.thread_id
    end

    def self.find_request_for_message(message)
      request = Request.find_by_streak_box_key(message.streak_box_key)
      return request if request

      email = message.subject.gsub(/^.+ \((.+)\).*$/, '\\1')
      request = Request.joins(:user).where(streak_box_key: nil, users: { email: email.strip.downcase }).last
      request
    end
  end
end
