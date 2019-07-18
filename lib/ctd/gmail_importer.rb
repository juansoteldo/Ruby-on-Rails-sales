require 'google/apis/gmail_v1'
require 'googleauth'
require 'googleauth/stores/file_token_store'
require 'fileutils'

module CTD
  class GmailImporter
    def self.threads(*params)
      params ||= [Settings.gmail.labels.design_requests]
      service.list_user_threads(ME, *params)&.threads
    end

    def self.messages(*params)
      params ||= [Settings.gmail.labels.design_requests]
      service.list_user_messages(ME, *params)&.messages
    end

    def self.message(id, *params)
      service.get_user_message(ME, id, *params)
    end

    def self.filter_threads(email)
      email = email.gsub(/\./, "\\.")
      threads.select { |t| t.snippet =~ /Email Address: #{email} /i }
    end

    def self.service
      return @service if @service
      @service = Google::Apis::GmailV1::GmailService.new
      @service.client_options.application_name = APPLICATION_NAME
      @service.authorization = authorize
      @service
    end

    def self.labels
      response = service.list_user_labels(ME)
      response.labels
    end

    ##
    # Ensure valid credentials, either by restoring from the saved credentials
    # files or intitiating an OAuth2 authorization. If authorization is required,
    # the user's default browser will be launched to approve the request.
    #
    # @return [Google::Auth::UserRefreshCredentials] OAuth2 credentials
    def self.authorize
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

    ME = "ME".freeze
    OOB_URI = 'urn:ietf:wg:oauth:2.0:oob'.freeze
    TOKEN_PATH = Rails.root.join("tmp/gmail_token.yaml").freeze
    SCOPE = Google::Apis::GmailV1::AUTH_GMAIL_READONLY
    CREDENTIALS_PATH = Rails.root.join("config", "gmail_credentials.json").freeze
    APPLICATION_NAME = "CTD API".freeze
  end
end
