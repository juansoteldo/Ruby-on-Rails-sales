module MostlyGmail
  class Message < Base
    def self.all(*params)
      service.list_user_messages(ME_ID, *params)&.messages&.map(&method(:new))
    end

    def self.find(id, *params)
      new get_user_message(ME_ID, id, *params)
    end

    def subject
      payload.headers.find { |h| h.name == "Subject" }&.value
    end

    def payload
      fetch unless @source.payload
      @source.payload
    end

    def fetch
      @source = @@service&.get_user_message(ME_ID, @source.id) || @source
    end
  end
end