# frozen_string_literal: true

module MostlyGmail
  class Message < Base
    def self.all(*params)
      service.list_user_messages(ME_ID, *params)&.messages&.map(&method(:new)) || []
    end

    def self.find(id, *params)
      new get_user_message(ME_ID, id, *params)
    end

    def self.new_design_requests
      Rails.cache.fetch( "gmail/new-design-requests", expires_in: 5.seconds) do
        all({label_ids: Settings.gmail.labels.new_design_requests})
      end
    end

    def self.design_requests
      Rails.cache.fetch( "gmail/new-design-requests", expires_in: 5.seconds) do
        all({label_ids: Settings.gmail.labels.design_requests})
      end
    end

    def subject
      payload.headers.find { |h| h.name == "Subject" }&.value
    end

    def streak_box_key
      payload.headers.find { |h| h.name == "X-CTD-Streak-Box-Key" }&.value
    end

    def payload
      fetch unless @source.payload
      @source.payload
    end

    def text_body
      payload.parts.find {|p| p.mime_type == "text/plain"}.body.data
    end

    # TODO: This should not be necessary
    def shortened_utf_8_text_body
      text_body.encode('utf-8', :invalid => :replace, :undef => :replace, :replace => '_').split("\n")[2..-1].join("\n")
    end

    def fetch
      @source = @@service&.get_user_message(ME_ID, @source.id) || @source
    end
  end
end