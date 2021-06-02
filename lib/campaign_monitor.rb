# frozen_string_literal: true

module CampaignMonitor

  def self.user_custom_fields(user)
    custom_fields = [
      { 'Key': 'user_id', 'Value': user.id },
      { 'Key': 'user_token', 'Value': user.authentication_token }
    ]

    if user.requests.any?
      req = user.requests.first

      req_fields = [
        { 'Key': 'Identify As', 'Value': user.identifies_as.to_s },
        { 'Key': 'Style', 'Value': req.style.to_s },
        { 'Key': 'Size', 'Value': req.size.to_s },
        { 'Key': 'BodyPosition', 'Value': req.position.to_s },
        { 'Key': 'Purchased', 'Value': TaskHelper.yesno(req.deposit_order_id) }
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

  def self.export_user_data(user)
    creds       = Rails.application.credentials
    list_id     = Rails.env.development? ? creds.cm[:dev_list_id] : creds.cm[:prod_list_id]
    username    = creds.cm[:username]
    
    basic_auth = {
      username: username,
      password: 'whatever'
    }

    headers = {
      'Content-Type': 'application/json'
    }

    if user.marketing_opt_in?
      url = "https://api.createsend.com/api/v3.2/subscribers/#{list_id}.json"
      body = {
        'EmailAddress': user.email,
        'Resubscribe': true,
        'ConsentToTrack': 'Yes',
        'Name': user.first_name.to_s,
        'CustomFields': user_custom_fields(user)
      }
    else
      url = "https://api.createsend.com/api/v3.2/subscribers/#{list_id}/unsubscribe.json"
      body = {
        'EmailAddress': user.email
      }
    end
    
    HTTParty.post(url,
      basic_auth: basic_auth,
      headers: headers,
      body: body.to_json
    )
  end

end