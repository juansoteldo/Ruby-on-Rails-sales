module CTD
  class MailImporter
    def self.import
      Gmail.connect(username, password) do |gmail|
      end
    end

    def self.username
      ENV["GMAIL_USERNAME"]
    end

    def self.password
      ENV["GMAIL_PASSWORD"]
    end
  end
end

require 'gmail'