# frozen_string_literal: true

require 'task_helper'

module Services
  class CampaignMonitor

    # TODO: refactor this further
    creds     = Rails.application.credentials
    base_url  = creds.cm[:url]
    username  = creds.cm[:username]
    env       = Rails.env.to_sym

    @marketing_list_id  = creds.cm[env][:marketing_list_id]
    @all_list_id        = creds.cm[env][:all_list_id]

    @add_to_marketing_url       = "#{base_url}/#{@marketing_list_id}.json"
    @add_to_all_url             = "#{base_url}/#{@all_list_id}.json"
    @remove_from_marketing_url  = "#{base_url}/#{@marketing_list_id}/unsubscribe.json"
    @remove_from_all_url        = "#{base_url}/#{@all_list_id}/unsubscribe.json"

    @get_subscriber_details_in_all        = "#{base_url}/#{@all_list_id}.json"
    @get_subscriber_details_in_marketing  = "#{base_url}/#{@marketing_list_id}.json"
    @delete_subscriber                    = "#{base_url}/#{@all_list_id}.json"

    @basic_auth = {
      username: username,
      password: 'whatever'
    }

    @headers = {
      'Content-Type': 'application/json'
    }

    def self.user_custom_fields(user)
      custom_fields = [
        { 'Key': 'user_id', 'Value': user.id },
        { 'Key': 'user_token', 'Value': user.authentication_token },
        { 'Key': 'subscribed_date', 'Value': user.created_at.strftime('%Y-%m-%d') },
        { 'Key': 'job_status', 'Value': user.job_status }
      ]

      if user.requests.any?
        req = user.requests.last

        req_fields = [
          { 'Key': 'Identify As', 'Value': user.identifies_as.to_s },
          { 'Key': 'Style', 'Value': req.style.to_s },
          { 'Key': 'Size', 'Value': req.size.to_s },
          { 'Key': 'BodyPosition', 'Value': req.position.to_s },
          { 'Key': 'Purchased', 'Value': TaskHelper.yesno(req.deposit_order_id) },
          { 'Key': 'quote_url', 'Value': req.quote_url },
          { 'Key': 'salesperson_email', 'Value': req.salesperson&.email || Settings.emails.lee },
          { 'Key': 'variant_price', 'Value': req.variant_price }
          # { 'Key': 'requests_statuses', 'Value': user.requests.map { |request| request.state }.join(',')} # Unused
        ]

        if !req.is_first_time.nil?
          req_fields << { 'Key': 'First Tattoo', 'Value': TaskHelper.yesno(req.is_first_time) }
        end

        if !req.has_color.nil?
          req_fields << { 'Key': 'Colour', 'Value': TaskHelper.yesno(req.has_color) }
        end

        if !req.has_cover_up.nil?
          req_fields << { 'Key': 'Coverup', 'Value': TaskHelper.yesno(req.has_cover_up) }
        end

        custom_fields += req_fields
      end

      custom_fields
    end

    def self.add_request_body(user)
      {
        'EmailAddress': user.email,
        'Name': user.first_name.to_s,
        'Resubscribe': false,
        'ConsentToTrack': 'yes',
        'CustomFields': user_custom_fields(user),
      }
    end

    def self.remove_request_body(user)
      {
        'EmailAddress': user.email,
      }
    end

    def self.parse_response(response)
      data = JSON.parse(response, symbolize_names: true)
      raise_exception(Exceptions::InvalidResponseError, response) if data.nil?
      raise_exception(Exceptions::NotFoundError, response) if data.code == 404
      return data
    end

    def self.raise_exception(exception_name, response)
      raise exception_name.new({ response: response.inspect, request: response.request.inspect })
    end

    def self.add_or_update_user_to_all_list(user)
      response = get_subscriber_details_in_all(user)
      data = parse_response(response)
      response_code = data[:Code]
      if response_code == 203
        add_user_to_all_list(user)
      elsif response_code == 1
        raise_exception(Exceptions::FailedRequestError, response)
      else
        update_user_to_all_list(user)
      end
    end
  
    # TODO: Change to add_user_to_list and add an argument to specify the url (add_to_all_url/add_to_marketing_url)
    def self.add_user_to_all_list(user)
      response = HTTParty.post(@add_to_all_url,
        basic_auth: @basic_auth,
        headers: @headers,
        body: add_request_body(user).to_json,
        format: :plain
      )
      raise_exception(Exceptions::InvalidResponseError, response) if response.code != 201
    end

    def self.add_user_to_marketing_list(user)
      response = HTTParty.post(@add_to_marketing_url,
        basic_auth: @basic_auth,
        headers: @headers,
        body: add_request_body(user).to_json,
        format: :plain
      )
      raise_exception(Exceptions::InvalidResponseError, response) if response.code != 201
    end

    def self.add_email_to_marketing_list(user)
      user = user[:user]
      req_body = { 
        'EmailAddress': user[:email], 
        'Name': user[:name], 
        'Resubscribe': false, 
        'ConsentToTrack': 'yes',
      }
      response = HTTParty.post(@add_to_marketing_url,
        basic_auth: @basic_auth,
        headers: @headers,
        body: req_body.to_json,
        format: :plain
      )
      raise_exception(Exceptions::InvalidResponseError, response) if response.code != 201
    end

    ### UPDATE SUBSCRIBER
    def self.update_user_to_all_list(user)
      response = HTTParty.put(@add_to_all_url,
        basic_auth: @basic_auth,
        headers: @headers,
        query: { email: user.email },
        body: add_request_body(user).to_json
      )
      raise_exception(Exceptions::InvalidResponseError, response) if response.code != 200
    end

    def self.update_user_to_marketing_list(user)
      response = HTTParty.put(@add_to_marketing_url,
        basic_auth: @basic_auth,
        headers: @headers,
        query: { email: user.email },
        body: add_request_body(user).to_json
      )
      raise_exception(Exceptions::InvalidResponseError, response) if response.code != 200
    end
    
    ### REMOVE SUBSCRIBER
    def self.remove_user_from_marketing_list(user)
      response = HTTParty.post(@remove_from_marketing_url,
        basic_auth: @basic_auth,
        headers: @headers,
        body: remove_request_body(user).to_json
      )
      raise_exception(Exceptions::InvalidResponseError, response) if response.code != 200
    end

    def self.remove_user_from_all_list(user)
      response = HTTParty.post(@remove_from_all_url,
        basic_auth: @basic_auth,
        headers: @headers,
        body: remove_request_body(user).to_json
      )
      raise_exception(Exceptions::InvalidResponseError, response) if response.code != 200
    end

    ### GET SUBSCRIBER
    def self.get_subscriber_details_in_all(user)
      response = HTTParty.get("#{@get_subscriber_details_in_all}?email=#{user.email}",
        basic_auth: @basic_auth,
        headers: @headers,
        format: :plain
      )
      raise_exception(Exceptions::InvalidResponseError, response) if response.code != 200
      return response
    end

    def self.get_subscriber_details_in_marketing(user)
      response = HTTParty.get("#{@get_subscriber_details_in_marketing}?email=#{user.email}",
        basic_auth: @basic_auth,
        headers: @headers,
      )
      raise_exception(Exceptions::InvalidResponseError, response) if response.code != 200
      return response
    end

    ### DELETE SUBSCRIBER
    def self.delete_subscriber(user)
      response = HTTParty.delete("#{@delete_subscriber}?email=#{user.email}",
        basic_auth: @basic_auth,
        headers: @headers,
      )
      raise_exception(Exceptions::InvalidResponseError, response) if response.code != 200
    end

    def self.send_transactional_email(smart_email_id, user)
      url = "https://api.createsend.com/api/v3.3/transactional/smartEmail/#{smart_email_id}/send"
      first_name = user.first_name
      request = user.requests.last
      message = {
        'To': ["#{first_name} <#{user.email}>"],
        'Data': {
          'firstname': first_name,
          'variant_price': request.variant_price,
          'quote_url': request.quote_url,
          'user_id': user.id,
          'email': user.email,
          'user_token': user.authentication_token
        },
        'ConsentToTrack': 'yes'
      }
      response = HTTParty.post(url,
        basic_auth: @basic_auth,
        headers: @headers,
        body: message.to_json,
      )
      raise_exception(Exceptions::InvalidResponseError, response) if response.nil? || response.code != 202
    end

    def self.process_webhook_events(data)
      directives = {
        'Deactivate' => false,
        'Subscribe' => true
      }

      data['Events'].each do |event|
        type = event['Type']

        user = User.find_by_email(event['EmailAddress'])
        next unless user

        case data['ListID']
        when @marketing_list_id
          user.update_column :marketing_opt_in, directives[type]
        when @all_list_id
          user.update_column :presales_opt_in, directives[type]
        end
      end
    end
  end
end
