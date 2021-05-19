# frozen_string_literal: true

require "google/apis/gmail_v1"
require "googleauth"
require "googleauth/stores/redis_token_store"
require "redis"
require "fileutils"

module MostlyGmail
  class Base
    @@service = nil

    def initialize(source)
      @source = source
    end

    def method_missing(symbol, *args)
      @source&.send(symbol, *args)
    end

    ME_ID = "ME"
    OOB_URI = "urn:ietf:wg:oauth:2.0:oob"
    SCOPE = Google::Apis::GmailV1::AUTH_GMAIL_MODIFY
    CREDENTIALS_PATH = Rails.root.join("config", "gmail_credentials.json").freeze
    APPLICATION_NAME = "CTD API"

    class << self
      #      protected

      def service
        return @@service if @@service

        @@service = Google::Apis::GmailV1::GmailService.new
        @@service.client_options.application_name = APPLICATION_NAME
        @@service.authorization = authorize
        @@service
      end

      def refresh_credentials!
        client_id = Google::Auth::ClientId.new Rails.application.credentials[:gmail][:client_id],
                                               Rails.application.credentials[:gmail][:client_secret]
        token_store = Google::Auth::Stores::RedisTokenStore.new(redis: Redis.new)
        authorizer = Google::Auth::UserAuthorizer.new(client_id, SCOPE, token_store)
        url = authorizer.get_authorization_url(base_url: OOB_URI)
        puts "Open the following URL in the browser and enter the " \
         "resulting code after authorization:\n" + url
        code = gets
        user_id = "default"
        authorizer.get_and_store_credentials_from_code(
          user_id: user_id, code: code, base_url: OOB_URI
        )
      end

      ##
      # Ensure valid credentials, either by restoring from the saved credentials
      # files or intitiating an OAuth2 authorization. If authorization is required,
      # the user's default browser will be launched to approve the request.
      #
      # @return [Google::Auth::UserRefreshCredentials] OAuth2 credentials
      def authorize
        client_id = Google::Auth::ClientId.new Rails.application.credentials[:gmail][:client_id],
                                               Rails.application.credentials[:gmail][:client_secret]
        token_store = Google::Auth::Stores::RedisTokenStore.new(redis: Redis.new)
        authorizer = Google::Auth::UserAuthorizer.new(client_id, SCOPE, token_store)
        user_id = "default"
        credentials = authorizer.get_credentials(user_id)
        if credentials.nil?
          url = authorizer.get_authorization_url(base_url: OOB_URI)
          puts "Open the following URL in the browser and enter the " \
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
