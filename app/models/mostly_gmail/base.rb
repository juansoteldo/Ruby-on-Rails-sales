# frozen_string_literal: true

require 'google/apis/gmail_v1'
require 'googleauth'
require 'googleauth/stores/file_token_store'
require 'fileutils'

module MostlyGmail
  class Base
    @@service = nil

    def initialize(source)
      @source = source
    end

    ME_ID = "ME".freeze
    OOB_URI = 'urn:ietf:wg:oauth:2.0:oob'.freeze
    TOKEN_PATH = Rails.root.join("tmp/gmail_token.yaml").freeze
    SCOPE = Google::Apis::GmailV1::AUTH_GMAIL_READONLY
    CREDENTIALS_PATH = Rails.root.join("config", "gmail_credentials.json").freeze
    APPLICATION_NAME = "CTD API".freeze

    class << self

      protected

      def method_missing(symbol, *args)
        @source.send(symbol, *args)
      end

      def service
        return @@service if @@service
        @@service = Google::Apis::GmailV1::GmailService.new
        @@service.client_options.application_name = APPLICATION_NAME
        @@service.authorization = authorize
        @@service
      end

      ##
      # Ensure valid credentials, either by restoring from the saved credentials
      # files or intitiating an OAuth2 authorization. If authorization is required,
      # the user's default browser will be launched to approve the request.
      #
      # @return [Google::Auth::UserRefreshCredentials] OAuth2 credentials
      def authorize
        client_id = Google::Auth::ClientId.from_file(CREDENTIALS_PATH)
        token_store = Google::Auth::Stores::FileTokenStore.new(file: TOKEN_PATH)
        authorizer = Google::Auth::UserAuthorizer.new(client_id, SCOPE, token_store)
        user_id = 'default'
        credentials = authorizer.get_credentials(user_id)
        if credentials.nil?
          url = authorizer.get_authorization_url(base_url: OOB_URI)
          puts 'Open the following URL in the browser and enter the ' \
         "resulting code after authorization:\n" + url
          code = gets
          credentials = authorizer.get_and_store_credentials_from_code(
              user_id: user_id, code: code, base_url: OOB_URI
          )
        end
        credentials
      end
    end
  end
end
