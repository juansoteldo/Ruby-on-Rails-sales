# frozen_string_literal: true

require 'task_helper'

module Services
  class CampaignMonitor

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
          { 'Key': 'requests_statuses', 'Value': user.requests.map { |request| request.state }.join(',')}
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

    def self.set_commons(user)
      creds         = Rails.application.credentials
      username      = creds.cm[:username]
      env           = Rails.env.to_sym
      
      @marketing_list_id   = creds.cm[env][:marketing_list_id]
      @all_list_id         = creds.cm[env][:all_list_id]

      cm_host                      = 'https://api.createsend.com/api/v3.2/subscribers'
      @add_to_marketing_url        = "#{cm_host}/#{@marketing_list_id}.json"
      @add_to_all_url              = "#{cm_host}/#{@all_list_id}.json"
      @remove_from_marketing_url   = "#{cm_host}/#{@marketing_list_id}/unsubscribe.json"
      @remove_from_all_url         = "#{cm_host}/#{@all_list_id}/unsubscribe.json"

      @get_subscriber_details_in_all = "#{cm_host}/#{@all_list_id}.json?email=#{user.email}"
      @get_subscriber_details_in_marketing = "#{cm_host}/#{@marketing_list_id}.json?email=#{user.email}"

      @delete_subscriber = "#{cm_host}/#{@all_list_id}.json?email=#{user.email}"

      @basic_auth = {
        username: username,
        password: 'whatever'
      }

      @headers = {
        'Content-Type': 'application/json'
      }
    end

    def self.add_request_body(user)
      {
        'EmailAddress': user.email,
        'Resubscribe': false,
        'ConsentToTrack': 'Yes',
        'Name': user.first_name.to_s,
        'CustomFields': user_custom_fields(user)
      }
    end

    def self.remove_request_body(user)
      {
        'EmailAddress': user.email
      }
    end
  
    def self.add_user_to_all_list(user)
      set_commons(user)
    
      HTTParty.post(@add_to_all_url,
        basic_auth: @basic_auth,
        headers: @headers,
        body: add_request_body(user).to_json
      )
    end

    def self.add_user_to_marketing_list(user)
      set_commons(user)

      HTTParty.post(@add_to_marketing_url,
        basic_auth: @basic_auth,
        headers: @headers,
        body: add_request_body(user).to_json
      )
    end

    def self.update_user_to_all_list(user)
      set_commons(user)
    
      HTTParty.put(@add_to_all_url,
        basic_auth: @basic_auth,
        headers: @headers,
        query: {email: user.email},
        body: add_request_body(user).to_json
      )
    end

    def self.update_user_to_marketing_list(user)
      set_commons(user)

      response = HTTParty.put(@add_to_marketing_url,
        basic_auth: @basic_auth,
        headers: @headers,
        query: {email: user.email}  ,
        body: add_request_body(user).to_json
      )
    end
    
    def self.remove_user_from_marketing_list(user)
      set_commons(user)

      HTTParty.post(@remove_from_marketing_url,
        basic_auth: @basic_auth,
        headers: @headers,
        body: remove_request_body(user).to_json
      )
    end

    def self.remove_user_from_all_list(user)
      set_commons(user)

      HTTParty.post(@remove_from_all_url,
        basic_auth: @basic_auth,
        headers: @headers,
        body: remove_request_body(user).to_json
      )
    end

    def self.get_subscriber_details_in_all(user)
      set_commons(user)

      HTTParty.get(@get_subscriber_details_in_all,
        basic_auth: @basic_auth,
        headers: @headers,
      )
    end

    def self.get_subscriber_details_in_marketing(user)
      set_commons(user)

      HTTParty.get(@get_subscriber_details_in_marketing,
        basic_auth: @basic_auth,
        headers: @headers,
      )
    end

    def self.delete_subscriber(user)
      set_commons(user)

      HTTParty.delete(@delete_subscriber,
        basic_auth: @basic_auth,
        headers: @headers,
      )
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
